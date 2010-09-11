require "spec_helper"
require "httpi/adapter/curb"

describe HTTPI::Adapter::Curb do
  include HelperMethods

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
        @adapter.headers = some_headers_hash
        @adapter.headers.should == some_headers_hash
      end
    end

    describe "#get" do
      before do
        @adapter.client.expects(:http_get)
        @adapter.client.expects(:response_code).returns(200)
        @adapter.client.expects(:headers).returns(some_headers_hash)
        @adapter.client.expects(:body_str).returns(some_html)
      end

      it "should return a valid HTTPI::Response" do
        @adapter.get(some_url).should be_a_valid_httpi_response
      end
    end

   describe "#post" do
     before do
       @adapter.client.expects(:http_post)
       @adapter.client.expects(:response_code).returns(200)
       @adapter.client.expects(:headers).returns(some_headers_hash)
       @adapter.client.expects(:body_str).returns(some_html)
     end

     it "should return a valid HTTPI::Response" do
       @adapter.post(some_url, some_html).should be_a_valid_httpi_response
     end
   end
  end

end
