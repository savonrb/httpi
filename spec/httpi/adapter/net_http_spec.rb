require "spec_helper"
require "integration/support/server"

describe HTTPI::Adapter::NetHTTP do

  subject(:adapter) { :net_http }

  context "http requests" do
    before :all do
      @server = IntegrationServer.run
    end

    after :all do
      @server.stop
    end

    context 'when socks is specified' do

      let(:socks_client) { mock('socks_client') }
      let(:request){HTTPI::Request.new(@server.url)}

      it 'uses Net::HTTP.SOCKSProxy as client' do
        socks_client.expects(:new).with(URI(@server.url).host, URI(@server.url).port).returns(:socks_client_instance)
        Net::HTTP.expects(:SOCKSProxy).with('localhost', 8080).returns socks_client

        request.proxy = 'socks://localhost:8080'
        adapter = HTTPI::Adapter::NetHTTP.new(request)

        expect(adapter.client).to eq(:socks_client_instance)
      end
    end

    it "sends and receives HTTP headers" do
      request = HTTPI::Request.new(@server.url + "x-header")
      request.headers["X-Header"] = "HTTPI"

      response = HTTPI.get(request, adapter)
      expect(response.body).to include("HTTPI")
    end

    it "executes GET requests" do
      response = HTTPI.get(@server.url, adapter)
      expect(response.body).to eq("get")
      expect(response.headers["Content-Type"]).to eq("text/plain")
    end

    it "executes POST requests" do
      response = HTTPI.post(@server.url, "<some>xml</some>", adapter)
      expect(response.body).to eq("post")
      expect(response.headers["Content-Type"]).to eq("text/plain")
    end

    it "executes HEAD requests" do
      response = HTTPI.head(@server.url, adapter)
      expect(response.code).to eq(200)
      expect(response.headers["Content-Type"]).to eq("text/plain")
    end

    it "executes PUT requests" do
      response = HTTPI.put(@server.url, "<some>xml</some>", adapter)
      expect(response.body).to eq("put")
      expect(response.headers["Content-Type"]).to eq("text/plain")
    end

    it "executes DELETE requests" do
      response = HTTPI.delete(@server.url, adapter)
      expect(response.body).to eq("delete")
      expect(response.headers["Content-Type"]).to eq("text/plain")
    end

    context "supports custom methods supported by Net::HTTP" do
      let(:request) do
        HTTPI::Request.new(@server.url).tap do|r|
          r.body = request_body if request_body
        end
      end

      let(:request_body) { nil }

      let(:response) { HTTPI.request(http_method, request, adapter) }

      shared_examples_for 'any supported custom method' do
        specify { expect(response.body).to eq(http_method.to_s) }
        specify { expect(response.headers["Content-Type"]).to eq('text/plain') }
      end

      context 'PATCH' do
        let(:http_method) { :patch }
        let(:request_body) { "<some>xml</some>" }

        it_behaves_like 'any supported custom method'
      end

      context 'UNSUPPORTED method' do
        let(:http_method) { :unsupported }

        specify { expect { response }.to raise_error HTTPI::NotSupportedError }
      end
    end

    it "supports basic authentication" do
      request = HTTPI::Request.new(@server.url + "basic-auth")
      request.auth.basic("admin", "secret")

      response = HTTPI.get(request, adapter)
      expect(response.body).to eq("basic-auth")
    end

    it "does not support digest authentication" do
      request = HTTPI::Request.new(@server.url + "digest-auth")
      request.auth.digest("admin", "secret")

      expect { HTTPI.get(request, adapter) }.
        to raise_error(HTTPI::NotSupportedError, /does not support HTTP digest authentication/)
    end

    it "supports ntlm authentication" do
      request = HTTPI::Request.new(@server.url + "ntlm-auth")
      request.auth.ntlm("tester", "vReqSoafRe5O")

      response = HTTPI.get(request, adapter)
      expect(response.body).to eq("ntlm-auth")
    end

    it 'does not support ntlm authentication when Net::NTLM is not available' do
      Net.expects(:const_defined?).with(:NTLM).returns false

      request = HTTPI::Request.new(@server.url + 'ntlm-auth')
      request.auth.ntlm("testing", "failures")

      expect { HTTPI.get(request, adapter) }.
        to raise_error(HTTPI::NotSupportedError, /Net::NTLM is not available/)
    end

    it "does not crash when authenticate header is missing (on second request)" do
      request = HTTPI::Request.new(@server.url + 'ntlm-auth')
      request.auth.ntlm("tester", "vReqSoafRe5O")

      expect { HTTPI.get(request, adapter) }.
        to_not raise_error

      expect { HTTPI.get(request, adapter) }.
        to_not raise_error
    end
  end

  # it does not support digest auth

  if RUBY_PLATFORM =~ /java/
    pending "Puma Server complains: SSL not supported on JRuby"
  else
    context "https requests" do
      before :all do
        @server = IntegrationServer.run(:ssl => true)
      end
      after :all do
        @server.stop
      end

      # it does not raise when no certificate was set up
      it "works when set up properly" do
        request = HTTPI::Request.new(@server.url)
        request.auth.ssl.ca_cert_file = IntegrationServer.ssl_ca_file

        response = HTTPI.get(request, adapter)
        expect(response.body).to eq("get")
      end
    end
  end

end
