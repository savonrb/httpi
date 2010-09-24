require "spec_helper"
require "httpi/adapter/curb"
require "httpi/request"

require "curb"

describe HTTPI::Adapter::Curb do
  let(:adapter) { HTTPI::Adapter::Curb.new }
  let(:curb) { Curl::Easy.any_instance }

  describe ".new" do
    it "should require the Curb gem" do
      HTTPI::Adapter::Curb.any_instance.expects(:require).with("curb")
      HTTPI::Adapter::Curb.new
    end
  end

  describe "#get" do
    before do
      curb.expects(:http_get)
      curb.expects(:response_code).returns(200)
      curb.expects(:headers).returns(Hash.new)
      curb.expects(:body_str).returns(Fixture.xml)
    end

    it "should return a valid HTTPI::Response" do
      request = HTTPI::Request.new :url => "http://example.com"
      adapter.get(request).should be_a_valid_httpi_response
    end
  end

  describe "#post" do
    before do
      curb.expects(:http_post)
      curb.expects(:response_code).returns(200)
      curb.expects(:headers).returns(Hash.new)
      curb.expects(:body_str).returns(Fixture.xml)
    end

    it "should return a valid HTTPI::Response" do
      request = HTTPI::Request.new :url => "http://example.com"
      adapter.post(request).should be_a_valid_httpi_response
    end
  end

  describe "#put" do
    before do
      curb.expects(:http_put)
      curb.expects(:response_code).returns(200)
      curb.expects(:headers).returns(Hash.new)
      curb.expects(:body_str).returns(Fixture.xml)
    end

    it "should return a valid HTTPI::Response" do
      request = HTTPI::Request.new :url => "http://example.com"
      adapter.put(request).should be_a_valid_httpi_response
    end
  end

  describe "#delete" do
    before do
      curb.expects(:http_delete)
      curb.expects(:response_code).returns(200)
      curb.expects(:headers).returns(Hash.new)
      curb.expects(:body_str).returns("")
    end

    it "should return a valid HTTPI::Response" do
      request = HTTPI::Request.new :url => "http://example.com"
      adapter.delete(request).should be_a_valid_httpi_response
    end
  end

end
