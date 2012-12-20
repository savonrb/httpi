require "spec_helper"
require "integration/support/server"

describe HTTPI::Adapter::Curb do

  # curb is not supported on jruby
  unless RUBY_PLATFORM =~ /java/

    subject(:adapter) { :curb }

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

      it "supports digest authentication" do
        request = HTTPI::Request.new(@server.url + "digest-auth")
        request.auth.digest("admin", "secret")

        response = HTTPI.get(request, adapter)
        response.body.should eq("digest-auth")
      end
    end

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

