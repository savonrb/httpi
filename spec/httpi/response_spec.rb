require "spec_helper"
require "httpi/response"

describe HTTPI::Response do
  let(:response) { HTTPI::Response.new 200, { "Content-Encoding" => "gzip" }, Fixture.gzip }

  describe "#code" do
    it "should return the HTTP response code" do
      response.code.should == 200
    end

    it "should always return an Integer" do
      response = HTTPI::Response.new "200", {}, ""
      response.code.should == 200
    end
  end

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
