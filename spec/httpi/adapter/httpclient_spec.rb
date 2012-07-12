require "spec_helper"
require "httpi/adapter/httpclient"
require "httpi/request"

require "httpclient"

describe HTTPI::Adapter::HTTPClient do
  let(:adapter) { HTTPI::Adapter::HTTPClient.new }
  let(:httpclient) { HTTPClient.any_instance }
  let(:ssl_config) { HTTPClient::SSLConfig.any_instance }

  describe "#get" do
    it "returns a valid HTTPI::Response" do
      httpclient.expects(:get).with(basic_request.url, nil, basic_request.headers).returns(http_message)
      adapter.get(basic_request).should match_response(:body => Fixture.xml)
    end
  end

  describe "#post" do
    it "returns a valid HTTPI::Response" do
      request = HTTPI::Request.new :url => "http://example.com", :body => Fixture.xml
      httpclient.expects(:post).with(request.url, request.body, request.headers).returns(http_message)

      adapter.post(request).should match_response(:body => Fixture.xml)
    end
  end

  describe "#head" do
    it "returns a valid HTTPI::Response" do
      httpclient.expects(:head).with(basic_request.url, nil, basic_request.headers).returns(http_message)
      adapter.head(basic_request).should match_response(:body => Fixture.xml)
    end
  end

  describe "#put" do
    it "returns a valid HTTPI::Response" do
      request = HTTPI::Request.new :url => "http://example.com", :body => Fixture.xml
      httpclient.expects(:put).with(request.url, request.body, request.headers).returns(http_message)

      adapter.put(request).should match_response(:body => Fixture.xml)
    end
  end

  describe "#delete" do
    it "returns a valid HTTPI::Response" do
      httpclient.expects(:delete).with(basic_request.url, basic_request.headers).returns(http_message(""))
      adapter.delete(basic_request).should match_response(:body => "")
    end
  end

  describe "settings:" do
    before { httpclient.stubs(:get).returns(http_message) }

    describe "proxy" do
      it "have should specs"
    end

    describe "connect_timeout" do
      it "is not set unless specified" do
        httpclient.expects(:connect_timeout=).never
        adapter.get(basic_request)
      end

      it "is set if specified" do
        request = basic_request { |request| request.open_timeout = 30 }

        httpclient.expects(:connect_timeout=).with(30)
        adapter.get(request)
      end
    end

    describe "receive_timeout" do
      it "is not set unless specified" do
        httpclient.expects(:receive_timeout=).never
        adapter.get(basic_request)
      end

      it "is set if specified" do
        request = basic_request { |request| request.read_timeout = 30 }

        httpclient.expects(:receive_timeout=).with(30)
        adapter.get(request)
      end
    end

    describe "set_auth" do
      it "is set for HTTP basic auth" do
        request = basic_request { |request| request.auth.basic "username", "password" }

        httpclient.expects(:set_auth).with(request.url, *request.auth.credentials)
        adapter.get(request)
      end

      it "is set for HTTP digest auth" do
        request = basic_request { |request| request.auth.digest "username", "password" }

        httpclient.expects(:set_auth).with(request.url, *request.auth.credentials)
        adapter.get(request)
      end
    end

    context "(for SSL client auth)" do
      let(:ssl_auth_request) do
        basic_request do |request|
          request.auth.ssl.cert_key_file = "spec/fixtures/client_key.pem"
          request.auth.ssl.cert_file = "spec/fixtures/client_cert.pem"
        end
      end

      it "client_cert, client_key and verify_mode should be set" do
        ssl_config.expects(:client_cert=).with(ssl_auth_request.auth.ssl.cert)
        ssl_config.expects(:client_key=).with(ssl_auth_request.auth.ssl.cert_key)
        ssl_config.expects(:verify_mode=).with(ssl_auth_request.auth.ssl.openssl_verify_mode)

        adapter.get(ssl_auth_request)
      end

      it "sets the client_ca if specified" do
        ssl_auth_request.auth.ssl.ca_cert_file = "spec/fixtures/client_cert.pem"
        ssl_config.expects(:client_ca=).with(ssl_auth_request.auth.ssl.ca_cert)

        adapter.get(ssl_auth_request)
      end
    end

    context "(for SSL client auth with a verify mode of :none with no certs provided)" do
      let(:ssl_auth_request) do
        basic_request do |request|
          request.auth.ssl.verify_mode = :none
        end
      end

      it "verify_mode should be set" do
        ssl_config.expects(:verify_mode=).with(ssl_auth_request.auth.ssl.openssl_verify_mode)

        adapter.get(ssl_auth_request)
      end

      it "does not set client_cert and client_key "do
        ssl_config.expects(:client_cert=).never
        ssl_config.expects(:client_key=).never

        adapter.get(ssl_auth_request)
      end

      it "does not raise an exception" do
        expect { adapter.get(ssl_auth_request) }.to_not raise_error
      end
    end
  end

  def http_message(body = Fixture.xml)
    message = HTTP::Message.new_response body
    message.header.set "Accept-encoding", "utf-8"
    message
  end

  def basic_request
    request = HTTPI::Request.new "http://example.com"
    yield request if block_given?
    request
  end

end
