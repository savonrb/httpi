require "spec_helper"
require "httpi/adapter/httpclient"

describe HTTPI::Adapter::HTTPClient do
  include HelperMethods

  before do
    @adapter = Class.new { include HTTPI::Adapter::HTTPClient }.new
  end

  describe "#setup" do
    it "should require the HTTPClient gem" do
      @adapter.expects(:require).with("httpclient")
      @adapter.setup
    end
  end

  context "after #setup:" do
    before { @adapter.setup }

    describe "#client" do
      it "should return a memoized HTTPClient instance" do
        client = @adapter.client
        
        client.should be_an(HTTPClient)
        client.should equal(@adapter.client)
      end
    end

    describe "#headers" do
      it "should default to return an empty Hash" do
        @adapter.headers.should == {}
      end
    end

    describe "#headers=" do
      it "should set a given Hash of HTTP headers" do
        @adapter.headers = some_headers_hash
        @adapter.headers.should == some_headers_hash
      end
    end

    describe "#get" do
      before do
        response = HTTP::Message.new_response some_html
        response.header.add *some_headers.first
        @adapter.client.expects(:get).with(some_url).returns(response)
      end

      it "should return a valid HTTPI::Response" do
        @adapter.get(some_url).should be_a_valid_httpi_response
      end
    end

    describe "#post" do
      before do
        response = HTTP::Message.new_response some_html
        response.header.add *some_headers.first
        @adapter.headers = some_headers_hash
        @adapter.client.expects(:post).with(some_url, some_html, some_headers_hash).returns(response)
      end

      it "should return a valid HTTPI::Response" do
        @adapter.post(some_url, some_html).should be_a_valid_httpi_response
      end
    end
  end

end
