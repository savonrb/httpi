require "spec_helper"
require "integration/support/server"

describe HTTPI::Adapter::NetHTTPPersistent do

  subject(:adapter) { :net_http_persistent }

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

    it "supports ntlm authentication" do
      pending "the net_http_persistent adapter does not yet support NTLM auth"
      # when net_http_persistent was added, net-http.rb and net-http-spec.rb seem to have been a starting point.
      # however, net_http_persistent doesn't implement the NTLM protocol.  Without an implementation, this is a 
      # vanilla GET which results in a 401 as designed.

      # compare httpi/lib/httpi/adapter/net_http.rb, 33, 67, 78 (impl of NTLM protocol on top of net_http)
      # with httpi/lib/httpi/adapter/net_http_persistent.rb:26 which is a straight passthru without NTLM
      
      # For the implementation of the Puma test app /ntlm-auth, see httpi/spec/integration/support/application.rb:50
      # (this is based on recorded exchange as mentioned in httpi/spec/integration/net_http_spec.rb:107)

      request = HTTPI::Request.new(@server.url + "ntlm-auth")
      request.auth.ntlm("tester", "vReqSoafRe5O")

      response = HTTPI.get(request, adapter)
      response.body.should eq("ntlm-auth")
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
