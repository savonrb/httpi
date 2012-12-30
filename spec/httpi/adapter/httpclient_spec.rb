require "spec_helper"
require "httpi/adapter/httpclient"
require "httpi/request"

HTTPI::Adapter.load_adapter(:httpclient)

describe HTTPI::Adapter::HTTPClient do
  let(:adapter)    { HTTPI::Adapter::HTTPClient.new(request) }
  let(:httpclient) { HTTPClient.any_instance }
  let(:ssl_config) { HTTPClient::SSLConfig.any_instance }
  let(:request)    { HTTPI::Request.new("http://example.com") }

  describe "#request(:get)" do
    it "returns a valid HTTPI::Response" do
      httpclient_expects(:get)
      adapter.request(:get).should match_response(:body => Fixture.xml)
    end
  end

  describe "#request(:post)" do
    it "returns a valid HTTPI::Response" do
      request.body = Fixture.xml
      httpclient_expects(:post)

      adapter.request(:post).should match_response(:body => Fixture.xml)
    end
  end

  describe "#request(:head)" do
    it "returns a valid HTTPI::Response" do
      httpclient_expects(:head)
      adapter.request(:head).should match_response(:body => Fixture.xml)
    end
  end

  describe "#request(:put)" do
    it "returns a valid HTTPI::Response" do
      request.body = Fixture.xml
      httpclient_expects(:put)

      adapter.request(:put).should match_response(:body => Fixture.xml)
    end
  end

  describe "#request(:delete)" do
    it "returns a valid HTTPI::Response" do
      httpclient_expects(:delete)
      adapter.request(:delete).should match_response(:body => Fixture.xml)
    end
  end

  describe "#request(:custom)" do
    it "returns a valid HTTPI::Response" do
      httpclient_expects(:custom)
      adapter.request(:custom).should match_response(:body => Fixture.xml)
    end
  end

  describe "settings:" do
    before { httpclient.stubs(:request).returns(http_message) }

    describe "proxy" do
      it "have should specs"
    end

    describe "connect_timeout" do
      it "is not set unless specified" do
        httpclient.expects(:connect_timeout=).never
        adapter.request(:get)
      end

      it "is set if specified" do
        request.open_timeout = 30

        httpclient.expects(:connect_timeout=).with(30)
        adapter.request(:get)
      end
    end

    describe "receive_timeout" do
      it "is not set unless specified" do
        httpclient.expects(:receive_timeout=).never
        adapter.request(:get)
      end

      it "is set if specified" do
        request.read_timeout = 30

        httpclient.expects(:receive_timeout=).with(30)
        adapter.request(:get)
      end
    end

    describe "set_auth" do
      it "is set for HTTP basic auth" do
        request.auth.basic "username", "password"

        httpclient.expects(:set_auth).with(request.url, *request.auth.credentials)
        adapter.request(:get)
      end

      it "is set for HTTP digest auth" do
        request.auth.digest "username", "password"

        httpclient.expects(:set_auth).with(request.url, *request.auth.credentials)
        adapter.request(:get)
      end
    end

    context "(for SSL client auth)" do
      before do
        request.auth.ssl.cert_key_file = "spec/fixtures/client_key.pem"
        request.auth.ssl.cert_file = "spec/fixtures/client_cert.pem"
      end

      it "client_cert, client_key and verify_mode should be set" do
        ssl_config.expects(:client_cert=).with(request.auth.ssl.cert)
        ssl_config.expects(:client_key=).with(request.auth.ssl.cert_key)
        ssl_config.expects(:verify_mode=).with(request.auth.ssl.openssl_verify_mode)

        adapter.request(:get)
      end

      it "sets the client_ca if specified" do
        request.auth.ssl.ca_cert_file = "spec/fixtures/client_cert.pem"
        ssl_config.expects(:add_trust_ca).with(request.auth.ssl.ca_cert_file)

        adapter.request(:get)
      end

      it 'should set the ssl_version if specified' do
        request.auth.ssl.ssl_version = :SSLv3
        ssl_config.expects(:ssl_version=).with(request.auth.ssl.ssl_version)

        adapter.request(:get)
      end
    end

    context "(for SSL client auth with a verify mode of :none with no certs provided)" do
      before do
        request.auth.ssl.verify_mode = :none
      end

      it "verify_mode should be set" do
        ssl_config.expects(:verify_mode=).with(request.auth.ssl.openssl_verify_mode)

        adapter.request(:get)
      end

      it "does not set client_cert and client_key "do
        ssl_config.expects(:client_cert=).never
        ssl_config.expects(:client_key=).never

        adapter.request(:get)
      end

      it "does not raise an exception" do
        expect { adapter.request(:get) }.to_not raise_error
      end
    end
  end

  def httpclient_expects(method)
    httpclient.expects(:request).
      with(method, request.url, nil, request.body, request.headers).
      returns(http_message)
  end

  def http_message(body = Fixture.xml)
    message = HTTP::Message.new_response body
    message.header.set "Accept-encoding", "utf-8"
    message
  end

end
