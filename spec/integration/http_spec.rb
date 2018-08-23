require "spec_helper"
require "integration/support/server"

describe HTTPI::Adapter::HTTP do

  subject(:adapter) { :http }

  context "http requests" do
    before :all do
      @server = IntegrationServer.run
    end

    after :all do
      @server.stop
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
      require "http"

      request = HTTPI::Request.new(@server.url + "timeout")
      request.read_timeout = 0.5 # seconds

      expect do
        HTTPI.get(request, adapter)
      end.to raise_exception(HTTP::TimeoutError)
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

    it "does not support ntlm authentication" do
      request = HTTPI::Request.new(@server.url + "ntlm-auth")
      request.auth.ntlm("tester", "vReqSoafRe5O")

      expect { HTTPI.get(request, adapter) }.
        to raise_error(HTTPI::NotSupportedError, /does not support NTLM digest authentication/)
    end

    it "supports chunked response" do
      skip("Needs investigation")
      request = HTTPI::Request.new(@server.url)
      res = ""
      request.on_body do |body|
        res += body
      end
      response = HTTPI.post(request, adapter)
      expect(res).to eq("post")
      expect(response.body).to eq("")
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

      it "raises when no certificate was set up" do
        expect { HTTPI.post(@server.url, "", adapter) }.to raise_error(HTTPI::SSLError)
      end

      it "works when set up properly" do
        request = HTTPI::Request.new(@server.url)
        request.auth.ssl.ca_cert_file = IntegrationServer.ssl_ca_file

        response = HTTPI.get(request, adapter)
        expect(response.body).to eq("get")
      end
    end
  end

end
