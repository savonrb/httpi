require "spec_helper"
require "httpi/adapter/curb"

describe HTTPI::Adapter::Curb do
  before do
    @adapter = Class.new { include HTTPI::Adapter::Curb }.new
  end

  describe "#setup" do
    it "should require the Curb gem" do
      @adapter.expects(:require).with("curb")
      @adapter.setup
    end
  end

  context "after #setup:" do
    before { @adapter.setup }

    describe "#client" do
      it "should return a memoized Curl::Easy instance" do
        client = @adapter.client
        
        client.should be_an(Curl::Easy)
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

    describe "#get" do
      before do
        @adapter.client.expects(:http_get)
        @adapter.client.expects(:response_code).returns(Some.response_code)
        @adapter.client.expects(:headers).returns(Some.headers)
        @adapter.client.expects(:body_str).returns(Fixture.xml)
      end

      it "should return a valid HTTPI::Response" do
        @adapter.get(Some.url).should be_a_valid_httpi_response
      end
    end

   describe "#post" do
     before do
       @adapter.client.expects(:http_post)
       @adapter.client.expects(:response_code).returns(Some.response_code)
       @adapter.client.expects(:headers).returns(Some.headers)
       @adapter.client.expects(:body_str).returns(Fixture.xml)
     end

     it "should return a valid HTTPI::Response" do
       @adapter.post(Some.url, Fixture.xml).should be_a_valid_httpi_response
     end
   end
  end

end
