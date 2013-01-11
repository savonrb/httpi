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

    it "sends and receives HTTP headers" do
      request = HTTPI::Request.new(@server.url + "x-header")
      request.headers["X-Header"] = "HTTPI"

      response = HTTPI.get(request, adapter)
      response.body.should include("HTTPI")
    end

    it "it supports headers with multiple values" do
      request = HTTPI::Request.new(@server.url + "cookies")

      response = HTTPI.get(request, adapter)
      cookies = ["cookie1=chip1; path=/", "cookie2=chip2; path=/"]
      response.headers["Set-Cookie"].should eq(cookies)
    end

    it "executes GET requests" do
      response = HTTPI.get(@server.url, adapter)
      response.body.should eq("get")
      response.headers["Content-Type"].should eq("text/plain")
    end

    it "executes POST requests" do
      response = HTTPI.post(@server.url, "<some>xml</some>", adapter)
      response.body.should eq("post")
      response.headers["Content-Type"].should eq("text/plain")
    end

    it "executes HEAD requests" do
      response = HTTPI.head(@server.url, adapter)
      response.code.should == 200
      response.headers["Content-Type"].should eq("text/plain")
    end

    it "executes PUT requests" do
      response = HTTPI.put(@server.url, "<some>xml</some>", adapter)
      response.body.should eq("put")
      response.headers["Content-Type"].should eq("text/plain")
    end

    it "executes DELETE requests" do
      response = HTTPI.delete(@server.url, adapter)
      response.body.should eq("delete")
      response.headers["Content-Type"].should eq("text/plain")
    end

    it "supports basic authentication" do
      request = HTTPI::Request.new(@server.url + "basic-auth")
      request.auth.basic("admin", "secret")

      response = HTTPI.get(request, adapter)
      response.body.should eq("basic-auth")
    end

    # it does not support digest authentication

    it "supports chunked response" do
      request = HTTPI::Request.new(@server.url)
      res = ""
      request.on_body do |body|
        res += body
      end
      response = HTTPI.post(request, adapter)
      res.should eq("post")
      response.body.to_s.should eq("")
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
  #   https://github.com/coldnebo/httpi/wiki/NTLM-Integration-Test-Plan
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
        response.body.should match(/iis-8\.png/)

        puts "EXTERNAL NTLM INTEGRATION TEST, response body:"
        puts response.body
      end
    end
  end

end
