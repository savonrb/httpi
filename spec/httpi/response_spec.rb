require "spec_helper"

describe HTTPI::Response do

  context "normally" do

    let(:response) do
      HTTPI::Response.new 200, some(:headers), fixture(:xml)
    end

    describe "#error?" do
      it "returns false" do
        response.should_not be_an_error
      end
    end

    describe "#headers" do
      it "returns the response headers" do
        response.headers.should == some(:headers)
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

  context "when empty" do
    let(:response) do
      HTTPI::Response.new 204, {}, nil
    end

    describe "#body" do
      it "returns an empty String" do
        response.body.should == ""
      end
    end
  end

  context "when multipart" do
    let(:response) do
      HTTPI::Response.new 200, { "Content-Type" => "multipart/related" }, "multipart"
    end

    describe "#multipart" do
      it "returns true" do
        response.should be_multipart
      end
    end
  end

  context "when erroneous" do
    let(:response) do
      HTTPI::Response.new 404, {}, ""
    end

    describe "#error?" do
      it "returns true" do
        response.should be_an_error
      end
    end
  end

  context "when gzipped" do
    let(:response) do
      HTTPI::Response.new 200, { "Content-Encoding" => "gzip" }, fixture(:gzip)
    end

    describe "#headers" do
      it "returns the HTTP response headers" do
        response.headers.should == { "Content-Encoding" => "gzip" }
      end
    end

    describe "#body" do
      it "returns the (gzip decoded) HTTP response body" do
        response.body.should == fixture(:xml)
      end

      it "bubbles Zlib errors" do
        arbitrary_error = Class.new(ArgumentError)
        Zlib::GzipReader.expects(:new).raises(arbitrary_error)
        expect { response.body }.to raise_error(arbitrary_error)
      end
    end

    describe "#raw_body" do
      it "returns the raw HTML response body" do
        response.raw_body.should == fixture(:gzip)
      end
    end
  end

  context "when DIME" do
    let(:response) do
      HTTPI::Response.new 200, { "Content-Type" => "application/dime" }, fixture(:dime)
    end

    describe "#headers" do
      it "returns the HTTP response headers" do
        response.headers.should == { "Content-Type" => "application/dime" }
      end
    end

    describe "#body" do
      it "returns the (dime decoded) HTTP response body" do
        response.body.should == fixture(:xml_dime)
      end
    end

    describe "#raw_body" do
      it "returns the raw HTML response body" do
        response.raw_body.should == fixture(:dime)
      end
    end

    describe "#attachments" do
      it "returns proper attachment when given a dime response" do
        response.attachments.first.data == File.read(File.expand_path("../../fixtures/attachment.gif", __FILE__))
      end
    end
  end

end
