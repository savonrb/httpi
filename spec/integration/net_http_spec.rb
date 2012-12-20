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
  end

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
