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

    context "when socks is specified" do
      let(:socks_client) { mock("socks_client") }
      let(:request) { HTTPI::Request.new(@server.url) }

      it "uses Net::HTTP.SOCKSProxy as client" do
        socks_client.expects(:new).with(URI(@server.url).host, URI(@server.url).port).returns(:socks_client_instance)
        Net::HTTP.expects(:SOCKSProxy).with("localhost", 8080).returns socks_client

        request.proxy = "socks://localhost:8080"
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

    it "it supports headers with multiple values" do
      request = HTTPI::Request.new(@server.url + "cookies")

      response = HTTPI.get(request, adapter)
      cookies = ["cookie1=chip1; path=/", "cookie2=chip2; path=/"]
      expect(response.headers["Set-Cookie"]).to eq(cookies)
    end

    it "it supports read timeout" do
      request = HTTPI::Request.new(@server.url + "timeout")
      request.read_timeout = 0.5 # seconds

      expect do
        HTTPI.get(request, adapter)
      end.to raise_exception(Net::ReadTimeout)
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

    context "custom methods" do
      let(:request) {
        HTTPI::Request.new(@server.url).tap do |r|
          r.body = request_body if request_body
        end
      }
      let(:request_body) { nil }
      let(:response) { HTTPI.request(http_method, request, adapter) }

      shared_examples_for "any supported custom method" do
        specify { response.body.should eq http_method.to_s }
        specify { response.headers["Content-Type"].should eq("text/plain") }
      end

      context "PATCH method" do
        let(:http_method) { :patch }
        let(:request_body) { "<some>xml</some>" }

        it_behaves_like "any supported custom method"
      end

      context "UNSUPPORTED method" do
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

    it "does not support ntlm authentication when Net::NTLM is not available" do
      Net.expects(:const_defined?).with(:NTLM).returns false

      request = HTTPI::Request.new(@server.url + "ntlm-auth")
      request.auth.ntlm("testing", "failures")

      expect { HTTPI.get(request, adapter) }.
        to raise_error(HTTPI::NotSupportedError, /Net::NTLM is not available/)
    end

    it "does not require ntlm when ntlm authenication is not requested" do
      HTTPI::Adapter::NetHTTP.any_instance.stubs(:check_net_ntlm_version!).raises(RuntimeError)
        request = HTTPI::Request.new(@server.url)
        expect(request.auth.ntlm?).to be false

        # make sure a request doesn't call ntlm check if we don't ask for it.
        expect { HTTPI.get(request, adapter) }.not_to raise_error
      HTTPI::Adapter::NetHTTP.any_instance.unstub(:check_net_ntlm_version!)
    end

    it "does check ntlm when ntlm authentication is requested" do
      request = HTTPI::Request.new(@server.url + "ntlm-auth")
      request.auth.ntlm("tester", "vReqSoafRe5O")

      expect { HTTPI.get(request, adapter) }.not_to raise_error

      # the check should also verify that the version of ntlm is supported and still fail if it isn't
      HTTPI::Adapter::NetHTTP.any_instance.stubs(:ntlm_version).returns("0.1.1")

        request = HTTPI::Request.new(@server.url + "ntlm-auth")
        request.auth.ntlm("tester", "vReqSoafRe5O")

        expect { HTTPI.get(request, adapter) }.to raise_error(ArgumentError, /Invalid version/)

      HTTPI::Adapter::NetHTTP.any_instance.unstub(:ntlm_version)
    end

    it "does not crash when authenticate header is missing (on second request)" do
      request = HTTPI::Request.new(@server.url + "ntlm-auth")
      request.auth.ntlm("tester", "vReqSoafRe5O")

      expect { HTTPI.get(request, adapter) }.
        to_not raise_error

      expect { HTTPI.get(request, adapter) }.
        to_not raise_error
    end

    it "supports chunked response" do
      request = HTTPI::Request.new(@server.url)
      res = ""
      request.on_body do |body|
        res += body
      end
      response = HTTPI.post(request, adapter)
      expect(res).to eq("post")
      expect(response.body.to_s).to eq("")
    end
  end

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

      # does not raise when no certificate was set up
      it "works when set up properly" do
        request = HTTPI::Request.new(@server.url)
        request.auth.ssl.ca_cert_file = IntegrationServer.ssl_ca_file

        response = HTTPI.get(request, adapter)
        expect(response.body).to eq("get")
      end
    end
  end

  # The built-in Rack IntegrationServer and specs support a basic simulated NTLM exchange
  # that does not require anything outside of the normal gem test infrastructure.
  #   (see spec/httpi/adapter/net_http_spec.rb: it "supports ntlm authentication"
  #    and spec/integration/support/application.rb: map "/ntlm-auth")
  # But since that simulated exchange is based on recorded traffic, you may wish to
  # run the following integration test against a real external NTLM server from time to time.
  #
  # This test must be specially enabled because it requires an external
  # Windows 2012 Server configured according to the instructions found here:
  #   https://github.com/savonrb/httpi/wiki/NTLM-Integration-Test-Plan
  #
  # Once you have that server running as instructed, you can include this test by setting
  # NTLM=external via the command line, e.g.:
  #   $ NTLM=external bundle exec rspec
  #
  if ENV["NTLM"]=="external"
    context "http request via NTLM" do
      it "works with NTLM connections" do
        user = "tester"
        pass = "vReqSoafRe5O"
        request = HTTPI::Request.new("http://ntlmtest/")
        request.auth.ntlm(user,pass)
        response = HTTPI.get(request, adapter)
        expect(response.code).to eq(200)
        expect(response.body).to match(/iis-8\.png/)

        puts "EXTERNAL NTLM INTEGRATION TEST, response body:"
        puts response.body
      end
    end
  end

end
