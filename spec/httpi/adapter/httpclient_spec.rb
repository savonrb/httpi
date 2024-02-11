require "spec_helper"
require "httpi/adapter/httpclient"
require "httpi/request"
require "integration/support/server"

HTTPI::Adapter.load_adapter(:httpclient)

describe HTTPI::Adapter::HTTPClient do
  let(:adapter)    { HTTPI::Adapter::HTTPClient.new(request) }
  let(:httpclient) { HTTPClient.any_instance }
  let(:ssl_config) { HTTPClient::SSLConfig.any_instance }
  let(:request)    { HTTPI::Request.new("http://example.com") }

  before :all do
    @server = IntegrationServer.run
  end

  after :all do
    @server.stop
  end

  describe "#request(:get)" do
    it "returns a valid HTTPI::Response" do
      httpclient_expects(:get)
      expect(adapter.request(:get)).to match_response(:body => Fixture.xml)
    end
  end

  describe "#request(:post)" do
    it "returns a valid HTTPI::Response" do
      request.body = Fixture.xml
      httpclient_expects(:post)

      expect(adapter.request(:post)).to match_response(:body => Fixture.xml)
    end
  end

  describe "#request(:head)" do
    it "returns a valid HTTPI::Response" do
      httpclient_expects(:head)
      expect(adapter.request(:head)).to match_response(:body => Fixture.xml)
    end
  end

  describe "#request(:put)" do
    it "returns a valid HTTPI::Response" do
      request.body = Fixture.xml
      httpclient_expects(:put)

      expect(adapter.request(:put)).to match_response(:body => Fixture.xml)
    end
  end

  describe "#request(:delete)" do
    it "returns a valid HTTPI::Response" do
      httpclient_expects(:delete)
      expect(adapter.request(:delete)).to match_response(:body => Fixture.xml)
    end
  end

  describe "#request(:custom)" do
    it "returns a valid HTTPI::Response" do
      httpclient_expects(:custom)
      expect(adapter.request(:custom)).to match_response(:body => Fixture.xml)
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

    describe "send_timeout" do
      it "is not set unless specified" do
        httpclient.expects(:send_timeout=).never
        adapter.request(:get)
      end

      it "is set if specified" do
        request.write_timeout = 30

        httpclient.expects(:send_timeout=).with(30)
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

    context "(for SSL without auth)" do
      before do
        request.ssl = true
      end

      it 'should set the ssl_version if specified' do
        request.auth.ssl.ssl_version = :SSLv3
        ssl_config.expects(:ssl_version=).with('SSLv3')

        adapter.request(:get)
      end

      it 'should set the ciphers if specified' do
        request.auth.ssl.ciphers = OpenSSL::SSL::SSLContext.new.ciphers
        ssl_config.expects(:ciphers=).with(request.auth.ssl.ciphers)

        adapter.request(:get)
      end
    end

    context "(for SSL client auth)" do
      before do
        request.auth.ssl.cert_key_file = "spec/fixtures/client_key.pem"
        request.auth.ssl.cert_file = "spec/fixtures/client_cert.pem"
      end

      it "send certificate regardless of state of SSL verify mode" do
        request.auth.ssl.verify_mode = :none
        ssl_config.expects(:client_cert=).with(request.auth.ssl.cert)
        ssl_config.expects(:client_key=).with(request.auth.ssl.cert_key)

        adapter.request(:get)
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
        ssl_config.expects(:ssl_version=).with('SSLv3')

        adapter.request(:get)
      end

      it 'raises error when min_version not nil' do
        request.auth.ssl.min_version = :TLS1_2
        expect{ adapter.request(:get) }.
          to raise_error(HTTPI::NotSupportedError, 'Httpclient adapter does not support #min_version or #max_version. Please, use #ssl_version instead')
      end
      it 'raises error when max_version not nil' do
        request.auth.ssl.max_version = :TLS1_2
        expect{ adapter.request(:get) }.
          to raise_error(HTTPI::NotSupportedError, 'Httpclient adapter does not support #min_version or #max_version. Please, use #ssl_version instead')
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

      it "does not raise an exception" do
        expect { adapter.request(:get) }.to_not raise_error
      end
    end
  end

  # TODO: ntlm_openssl3 https://github.com/WinRb/rubyntlm/issues/57
  xit "supports NTLM authentication" do
    request = HTTPI::Request.new(@server.url + "ntlm-auth")

    request.auth.ntlm("tester", "vReqSoafRe5O")
    response = HTTPI.get(request, :httpclient)
    expect(response.body).to eq("ntlm-auth")
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
