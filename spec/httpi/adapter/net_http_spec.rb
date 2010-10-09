require "spec_helper"
require "httpi/adapter/net_http"
require "httpi/request"

describe HTTPI::Adapter::NetHTTP do

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
    before do
      @request = HTTPI::Request.new :url => "http://example.com"
      stub_request(:get, @request.url.to_s).to_return(:body => Fixture.xml)
    end

    it "should return a valid HTTPI::Response" do
      adapter(@request).get(@request).should match_response(:body => Fixture.xml)
    end
  end

  describe "#post" do
    before do
      @request = HTTPI::Request.new :url => "http://example.com", :body => Fixture.xml
      stub_request(:post, @request.url.to_s).with(:body => @request.body).to_return(:body => Fixture.xml)
    end

    it "should return a valid HTTPI::Response" do
      adapter(@request).post(@request).should match_response(:body => Fixture.xml)
    end
  end

  describe "#head" do
    before do
      @request = HTTPI::Request.new :url => "http://example.com"
      stub_request(:head, @request.url.to_s).to_return(:body => Fixture.xml)
    end

    it "should return a valid HTTPI::Response" do
      adapter(@request).head(@request).should match_response(:body => Fixture.xml)
    end
  end

  describe "#put" do
    before do
      @request = HTTPI::Request.new :url => "http://example.com", :body => Fixture.xml
      stub_request(:put, @request.url.to_s).with(:body => @request.body).to_return(:body => Fixture.xml)
    end

    it "should return a valid HTTPI::Response" do
      adapter(@request).put(@request).should match_response(:body => Fixture.xml)
    end
  end

  describe "#delete" do
    before do
      @request = HTTPI::Request.new :url => "http://example.com"
      stub_request(:delete, @request.url.to_s)
    end

    it "should return a valid HTTPI::Response" do
      adapter(@request).delete(@request).should match_response(:body => "")
    end
  end

end
