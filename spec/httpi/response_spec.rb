require "spec_helper"
require "httpi/response"

describe HTTPI::Response do

  context "normal" do
    let(:response) { HTTPI::Response.new 200, {}, Fixture.xml }

    describe "#error?" do
      it "returns false" do
        response.should_not be_an_error
      end
    end

    describe "#headers" do
      it "returns the HTTP response headers" do
        response.headers.should == {}
      end
    end

    describe "#code" do
      it "returns the HTTP response code" do
        response.code.should == 200
      end

      it "always returns an Integer" do
        response = HTTPI::Response.new "200", {}, ""
        response.code.should == 200
      end
    end

    describe "#multipart" do
      it "returns false" do
        response.should_not be_multipart
      end
    end
  end

  context "empty" do
    let(:response) { HTTPI::Response.new 204, {}, nil }

    describe "#body" do
      it "returns an empty String" do
        response.body.should == ""
      end
    end
  end

  context "multipart" do
    let(:response) { HTTPI::Response.new 200, { "Content-Type" => "multipart/related" }, "multipart" }

    describe "#multipart" do
      it "returns true" do
        response.should be_multipart
      end
    end
  end

  context "error" do
    let(:response) { HTTPI::Response.new 404, {}, "" }

    describe "#error?" do
      it "returns true" do
        response.should be_an_error
      end
    end
  end

  context "gzipped" do
    let(:response) { HTTPI::Response.new 200, { "Content-Encoding" => "gzip" }, Fixture.gzip }

    describe "#headers" do
      it "returns the HTTP response headers" do
        response.headers.should == { "Content-Encoding" => "gzip" }
      end
    end

    describe "#body" do
      it "returns the (gzip decoded) HTTP response body" do
        response.body.should == Fixture.xml
      end

      it "bubbles Zlib errors" do
        arbitrary_error = Class.new(ArgumentError)
        Zlib::GzipReader.expects(:new).raises(arbitrary_error)
        expect { response.body }.to raise_error(arbitrary_error)
      end
    end

    describe "#raw_body" do
      it "returns the raw HTML response body" do
        response.raw_body.should == Fixture.gzip
      end
    end
  end

  context "DIME" do
    let(:response) { HTTPI::Response.new 200, { "Content-Type" => "application/dime" }, Fixture.dime }

    describe "#headers" do
      it "returns the HTTP response headers" do
        response.headers.should == { "Content-Type" => "application/dime" }
      end
    end

    describe "#body" do
      it "returns the (dime decoded) HTTP response body" do
        response.body.should == Fixture.xml_dime
      end
    end

    describe "#raw_body" do
      it "returns the raw HTML response body" do
        response.raw_body.should == Fixture.dime
      end
    end

    describe "#attachments" do
      it "returns proper attachment when given a dime response" do
        response.attachments.first.data == File.read(File.expand_path("../../fixtures/attachment.gif", __FILE__))
      end
    end
  end

end
