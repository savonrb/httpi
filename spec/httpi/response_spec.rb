require "spec_helper"
require "httpi/response"

describe HTTPI::Response do
  before do
    @response = HTTPI::Response.new Some.response_code, Some.headers, Fixture.gzip
  end

  describe "#code" do
    it "should return the HTTP response code" do
      @response.code.should == Some.response_code
    end
  end

  describe "#code" do
    it "should return the HTTP response headers" do
      @response.headers.should == Some.headers
    end
  end

  describe "#body" do
    it "should return the (gzip decoded) HTTP response body" do
      @response.body.should == "A short gzip encoded message\n"
    end
  end

  describe "#raw_body" do
    it "should return the raw HTML response body" do
      @response.raw_body.should == Fixture.gzip
    end
  end

end
