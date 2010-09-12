require "spec_helper"
require "httpi/adapter/httpclient"

describe HTTPI::Adapter::HTTPClient do
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
        @adapter.headers = Some.headers
        @adapter.headers.should == Some.headers
      end
    end

    describe "#proxy" do
      it "should set the proxy server to use" do
        @adapter.proxy = Some.proxy_url
        @adapter.proxy.should == URI(Some.proxy_url)
      end

      it "should accept a URI" do
        @adapter.proxy = URI(Some.proxy_url)
        @adapter.proxy.should == URI(Some.proxy_url)
      end
    end

    describe "#auth" do
      it "should set authentication credentials" do
        @adapter.client.expects(:set_auth).with(nil, "username", "password")
        @adapter.auth "username", "password"
      end
    end

    describe "#get" do
      before do
        response = HTTP::Message.new_response Fixture.xml
        response.header.add *Some.headers.to_a.first
        @adapter.client.expects(:get).with(Some.url).returns(response)
      end

      it "should return a valid HTTPI::Response" do
        @adapter.get(Some.url).should be_a_valid_httpi_response
      end
    end

    describe "#post" do
      before do
        response = HTTP::Message.new_response Fixture.xml
        response.header.add *Some.headers.to_a.first
        @adapter.headers = Some.headers
        @adapter.client.expects(:post).with(Some.url, Fixture.xml, Some.headers).returns(response)
      end

      it "should return a valid HTTPI::Response" do
        @adapter.post(Some.url, Fixture.xml).should be_a_valid_httpi_response
      end
    end
  end

end
