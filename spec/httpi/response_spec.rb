require "spec_helper"
require "httpi/response"

describe HTTPI::Response do
  let(:response) { HTTPI::Response.new 200, { "Content-Encoding" => "gzip" }, Fixture.xml }

  describe "#code" do
    it "should return the HTTP response code" do
      response.code.should == 200
    end

    it "should always return an Integer" do
      response = HTTPI::Response.new "200", {}, ""
      response.code.should == 200
    end
  end

end

describe HTTPI::Response, "gzip" do
  let(:response) { HTTPI::Response.new 200, { "Content-Encoding" => "gzip" }, Fixture.gzip }

  describe "#headers" do
    it "should return the HTTP response headers" do
      response.headers.should == { "Content-Encoding" => "gzip" }
    end
  end

  describe "#body" do
    it "should return the (gzip decoded) HTTP response body" do
      response.body.should == Fixture.xml
    end
  end

  describe "#raw_body" do
    it "should return the raw HTML response body" do
      response.raw_body.should == Fixture.gzip
    end
  end

end

describe HTTPI::Response, "DIME" do
  let(:response) { HTTPI::Response.new 200, { "Content-Type" => "application/dime" }, Fixture.dime }

  describe "#headers" do
    it "should return the HTTP response headers" do
      response.headers.should == { "Content-Type" => "application/dime" }
    end
  end

  describe "#body" do
    it "should return the (dime decoded) HTTP response body" do
      response.body.should == Fixture.xml_dime
    end
  end

  describe "#raw_body" do
    it "should return the raw HTML response body" do
      response.raw_body.should == Fixture.dime
    end
  end

  describe "#attachments" do
    it "should return proper attachment when given a dime response" do
      response.attachments.first.data == File.read(File.expand_path("../../fixtures/attachment.gif", __FILE__))
    end
  end

end
