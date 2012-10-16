require "spec_helper"
require "httpi/adapter/net_http"
require "httpi/request"

HTTPI::Adapter.load_adapter(:net_http)

describe HTTPI::Adapter::NetHTTP do
  let(:net_http) { Net::HTTP.any_instance }
  let(:basic_response) { { :body => Fixture.xml, :headers => { "Accept-encoding" => "utf-8" } } }

  def adapter(request)
    @adapter ||= HTTPI::Adapter::NetHTTP.new request
  end

  describe "#request(:get)" do
    it "should return a valid HTTPI::Response" do
      stub_request(:get, basic_request.url.to_s).to_return(basic_response)
      adapter(basic_request).request(:get, basic_request).should match_response(:body => Fixture.xml)
    end
  end

  describe "#request(:post)" do
    it "should return a valid HTTPI::Response" do
      request = HTTPI::Request.new :url => "http://example.com", :body => Fixture.xml
      stub_request(:post, request.url.to_s).with(:body => request.body).to_return(basic_response)

      adapter(request).request(:post, request).should match_response(:body => Fixture.xml)
    end
  end

  describe "#request(:head)" do
    it "should return a valid HTTPI::Response" do
      stub_request(:head, basic_request.url.to_s).to_return(basic_response)
      adapter(basic_request).request(:head, basic_request).should match_response(:body => Fixture.xml)
    end
  end

  describe "#request(:put)" do
    it "should return a valid HTTPI::Response" do
      request = HTTPI::Request.new(
        :url     => "http://example.com",
        :headers => { "Accept-encoding" => "utf-8" },
        :body    => Fixture.xml
      )
      stub_request(:put, request.url.to_s).with(:body => request.body).to_return(basic_response)

      adapter(request).request(:put, request).should match_response(:body => Fixture.xml)
    end
  end

  describe "#request(:delete)" do
    it "should return a valid HTTPI::Response" do
      stub_request(:delete, basic_request.url.to_s).to_return(basic_response)
      adapter(basic_request).request(:delete, basic_request).should match_response(:body => Fixture.xml)
    end
  end

  describe "#request(:custom)" do
    it "raises a NotSupportedError" do
      expect { adapter(basic_request).request(:custom, basic_request) }.
        to raise_error(HTTPI::NotSupportedError, "Net::HTTP does not support custom HTTP methods")
    end
  end

  describe "settings:" do
    before { stub_request(:get, basic_request.url.to_s) }

    describe "use_ssl" do
      it "should be set to false for non-SSL requests" do
        net_http.expects(:use_ssl=).with(false)
        adapter(basic_request).request(:get, basic_request)
      end

      it "should be set to true for SSL requests" do
        request = basic_request { |request| request.ssl = true }

        net_http.expects(:use_ssl=).with(true)
        adapter(request).request(:get, request)
      end
    end

    describe "open_timeout" do
      it "should not be set if not specified" do
        net_http.expects(:open_timeout=).never
        adapter(basic_request).request(:get, basic_request)
      end

      it "should be set if specified" do
        request = basic_request { |request| request.open_timeout = 30 }

        net_http.expects(:open_timeout=).with(30)
        adapter(request).request(:get, request)
      end
    end

    describe "read_timeout" do
      it "should not be set if not specified" do
        net_http.expects(:read_timeout=).never
        adapter(basic_request).request(:get, basic_request)
      end

      it "should be set if specified" do
        request = basic_request { |request| request.read_timeout = 30 }

        net_http.expects(:read_timeout=).with(30)
        adapter(request).request(:get, request)
      end
    end

    describe "basic_auth" do
      it "should be set for HTTP basic auth" do
        request = basic_request { |request| request.auth.basic "username", "password" }

        stub_request(:get, "http://username:password@example.com")
        Net::HTTP::Get.any_instance.expects(:basic_auth).with(*request.auth.credentials)
        adapter(request).request(:get, request)
      end
    end

    context "(for SSL client auth)" do
      let(:ssl_auth_request) do
        basic_request do |request|
          request.auth.ssl.cert_key_file = "spec/fixtures/client_key.pem"
          request.auth.ssl.cert_file = "spec/fixtures/client_cert.pem"
        end
      end

      it "key, cert and verify_mode should be set" do
        net_http.expects(:cert=).with(ssl_auth_request.auth.ssl.cert)
        net_http.expects(:key=).with(ssl_auth_request.auth.ssl.cert_key)
        net_http.expects(:verify_mode=).with(ssl_auth_request.auth.ssl.openssl_verify_mode)

        adapter(ssl_auth_request).request(:get, ssl_auth_request)
      end

      it "should set the client_ca if specified" do
        ssl_auth_request.auth.ssl.ca_cert_file = "spec/fixtures/client_cert.pem"
        net_http.expects(:ca_file=).with(ssl_auth_request.auth.ssl.ca_cert_file)

        adapter(ssl_auth_request).request(:get, ssl_auth_request)
      end

      it 'should set the ssl_version if specified' do
        ssl_auth_request.auth.ssl.ssl_version = :SSLv3
        net_http.expects(:ssl_version=).with(ssl_auth_request.auth.ssl.ssl_version)

        adapter(ssl_auth_request).request(:get, ssl_auth_request)
      end
    end
  end

  def basic_request
    request = HTTPI::Request.new "http://example.com"
    yield request if block_given?
    request
  end

end
