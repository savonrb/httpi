require "spec_helper"
require "httpi/adapter/net_http"
require "httpi/request"

describe HTTPI::Adapter::NetHTTP do
  let(:net_http) { Net::HTTP.any_instance }

  def adapter(request)
    @adapter ||= HTTPI::Adapter::NetHTTP.new request
  end

  describe ".new" do
    it "should require the Net::HTTP library" do
      HTTPI::Adapter::NetHTTP.any_instance.expects(:require).with("net/https")
      HTTPI::Adapter::NetHTTP.new HTTPI::Request.new(:url => "http://example.com")
    end
  end

  describe "#get" do
    it "should return a valid HTTPI::Response" do
      stub_request(:get, basic_request.url.to_s).to_return(:body => Fixture.xml)
      adapter(basic_request).get(basic_request).should match_response(:body => Fixture.xml)
    end
  end

  describe "#post" do
    it "should return a valid HTTPI::Response" do
      request = HTTPI::Request.new :url => "http://example.com", :body => Fixture.xml
      stub_request(:post, request.url.to_s).with(:body => request.body).to_return(:body => Fixture.xml)
      
      adapter(request).post(request).should match_response(:body => Fixture.xml)
    end
  end

  describe "#head" do
    it "should return a valid HTTPI::Response" do
      stub_request(:head, basic_request.url.to_s).to_return(:body => Fixture.xml)
      adapter(basic_request).head(basic_request).should match_response(:body => Fixture.xml)
    end
  end

  describe "#put" do
    it "should return a valid HTTPI::Response" do
      request = HTTPI::Request.new :url => "http://example.com", :body => Fixture.xml
      stub_request(:put, request.url.to_s).with(:body => request.body).to_return(:body => Fixture.xml)
      
      adapter(request).put(request).should match_response(:body => Fixture.xml)
    end
  end

  describe "#delete" do
    it "should return a valid HTTPI::Response" do
      stub_request(:delete, basic_request.url.to_s)
      adapter(basic_request).delete(basic_request).should match_response(:body => "")
    end
  end

  describe "settings:" do
    before { stub_request(:get, basic_request.url.to_s) }

    describe "use_ssl" do
      it "should be set to false for non-SSL requests" do
        net_http.expects(:use_ssl=).with(false)
        adapter(basic_request).get(basic_request)
      end

      it "should be set to true for SSL requests" do
        request = basic_request { |request| request.ssl = true }
        
        net_http.expects(:use_ssl=).with(true)
        adapter(request).get(request)
      end
    end

    describe "open_timeout" do
      it "should not be set if not specified" do
        net_http.expects(:open_timeout=).never
        adapter(basic_request).get(basic_request)
      end

      it "should be set if specified" do
        request = basic_request { |request| request.open_timeout = 30 }
        
        net_http.expects(:open_timeout=).with(30)
        adapter(request).get(request)
      end
    end

    describe "read_timeout" do
      it "should not be set if not specified" do
        net_http.expects(:read_timeout=).never
        adapter(basic_request).get(basic_request)
      end

      it "should be set if specified" do
        request = basic_request { |request| request.read_timeout = 30 }
        
        net_http.expects(:read_timeout=).with(30)
        adapter(request).get(request)
      end
    end

    describe "basic_auth" do
      it "should be set for HTTP basic auth" do
        request = basic_request { |request| request.auth.basic "username", "password" }
        
        stub_request(:get, "http://username:password@example.com")
        Net::HTTP::Get.any_instance.expects(:basic_auth).with(*request.auth.credentials)
        adapter(request).get(request)
      end
    end
  end

  def basic_request
    request = HTTPI::Request.new "http://example.com"
    yield request if block_given?
    request
  end

end
