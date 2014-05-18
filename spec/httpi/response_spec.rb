require "spec_helper"
require "httpi/response"

describe HTTPI::Response do

  context "normal" do
    let(:response) { HTTPI::Response.new 200, {}, Fixture.xml }

    describe "#error?" do
      it "returns false" do
        expect(response).not_to be_an_error
      end
    end

    describe "#headers" do
      it "returns the HTTP response headers" do
        expect(response.headers).to eq({})
      end
    end

    describe "#code" do
      it "returns the HTTP response code" do
        expect(response.code).to eq(200)
      end

      it "always returns an Integer" do
        response = HTTPI::Response.new "200", {}, ""
        expect(response.code).to eq(200)
      end
    end

    describe "#multipart" do
      it "returns false" do
        expect(response).not_to be_multipart
      end
    end

    describe "#cookies" do
      it "returns an empty list" do
        expect(response.cookies).to eq([])
      end
    end
  end

  context "with cookies" do
    let(:response) { HTTPI::Response.new 200, { "Set-Cookie" => "some-cookie=choc-chip; Path=/; HttpOnly" }, "" }

    describe "#cookies" do
      it "returns a list of cookies" do
        cookie = response.cookies.first
        expect(cookie).to be_a(HTTPI::Cookie)
      end
    end
  end

  context "empty" do
    let(:response) { HTTPI::Response.new 204, {}, nil }

    describe "#body" do
      it "returns an empty String" do
        expect(response.body).to eq("")
      end
    end
  end

  context "multipart" do
    let(:response) { HTTPI::Response.new 200, { "Content-Type" => "multipart/related" }, "multipart" }

    describe "#multipart" do
      it "returns true" do
        expect(response).to be_multipart
      end
    end
  end

  context "error" do
    let(:response) { HTTPI::Response.new 404, {}, "" }

    describe "#error?" do
      it "returns true" do
        expect(response).to be_an_error
      end
    end
  end

  context "gzipped" do
    let(:response) { HTTPI::Response.new 200, { "Content-Encoding" => "gzip" }, Fixture.gzip }

    describe "#headers" do
      it "returns the HTTP response headers" do
        expect(response.headers).to eq({ "Content-Encoding" => "gzip" })
      end
    end

    describe "#body" do
      it "returns the (gzip decoded) HTTP response body" do
        expect(response.body).to eq(Fixture.xml)
      end

      it "bubbles Zlib errors" do
        arbitrary_error = Class.new(ArgumentError)
        Zlib::GzipReader.expects(:new).raises(arbitrary_error)
        expect { response.body }.to raise_error(arbitrary_error)
      end
    end

    describe "#raw_body" do
      it "returns the raw HTML response body" do
        expect(response.raw_body).to eq(Fixture.gzip)
      end
    end
  end

  context "DIME" do
    let(:response) { HTTPI::Response.new 200, { "Content-Type" => "application/dime" }, Fixture.dime }

    describe "#headers" do
      it "returns the HTTP response headers" do
        expect(response.headers).to eq({ "Content-Type" => "application/dime" })
      end
    end

    describe "#body" do
      it "returns the (dime decoded) HTTP response body" do
        expect(response.body).to eq(Fixture.xml_dime)
      end
    end

    describe "#raw_body" do
      it "returns the raw HTML response body" do
        expect(response.raw_body).to eq(Fixture.dime)
      end
    end

    describe "#attachments" do
      it "returns proper attachment when given a dime response" do
        response.attachments.first.data == File.read(File.expand_path("../../fixtures/attachment.gif", __FILE__))
      end
    end
  end

end
