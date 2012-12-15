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
  end

  # it does not support digest auth

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


__END__

  describe "#request(:get)" do
    it "should return a valid HTTPI::Response" do
      stub_request(:get, request.url.to_s).to_return(basic_response)
      adapter.request(:get).should match_response(:body => Fixture.xml)
    end
  end

  describe "#request(:post)" do
    it "should return a valid HTTPI::Response" do
      request.body = Fixture.xml
      stub_request(:post, request.url.to_s).with(:body => request.body).to_return(basic_response)

      adapter.request(:post).should match_response(:body => Fixture.xml)
    end
  end

  describe "#request(:head)" do
    it "should return a valid HTTPI::Response" do
      stub_request(:head, request.url.to_s).to_return(basic_response)
      adapter.request(:head).should match_response(:body => Fixture.xml)
    end
  end

  describe "#request(:put)" do
    it "should return a valid HTTPI::Response" do
      request.url     = "http://example.com"
      request.headers = { "Accept-encoding" => "utf-8" }
      request.body    = Fixture.xml

      stub_request(:put, request.url.to_s).with(:body => request.body).to_return(basic_response)

      adapter.request(:put).should match_response(:body => Fixture.xml)
    end
  end

  describe "#request(:delete)" do
    it "should return a valid HTTPI::Response" do
      stub_request(:delete, request.url.to_s).to_return(basic_response)
      adapter.request(:delete).should match_response(:body => Fixture.xml)
    end
  end

  describe "#request(:custom)" do
    it "raises a NotSupportedError" do
      expect { adapter.request(:custom) }.
        to raise_error(HTTPI::NotSupportedError, "Net::HTTP does not support custom HTTP methods")
    end
  end

  describe "settings:" do
    before { stub_request(:get, request.url.to_s) }

    describe "use_ssl" do
      it "should be set to false for non-SSL requests" do
        net_http.expects(:use_ssl=).with(false)
        adapter.request(:get)
      end

      it "should be set to true for SSL requests" do
        request.ssl = true

        net_http.expects(:use_ssl=).with(true)
        adapter.request(:get)
      end
    end

    describe "open_timeout" do
      it "should not be set if not specified" do
        net_http.expects(:open_timeout=).never
        adapter.request(:get)
      end

      it "should be set if specified" do
        request.open_timeout = 30

        net_http.expects(:open_timeout=).with(30)
        adapter.request(:get)
      end
    end

    describe "read_timeout" do
      it "should not be set if not specified" do
        net_http.expects(:read_timeout=).never
        adapter.request(:get)
      end

      it "should be set if specified" do
        request.read_timeout = 30

        net_http.expects(:read_timeout=).with(30)
        adapter.request(:get)
      end
    end

    describe "basic_auth" do
      it "should be set for HTTP basic auth" do
        request.auth.basic "username", "password"

        stub_request(:get, "http://username:password@example.com")
        Net::HTTP::Get.any_instance.expects(:basic_auth).with(*request.auth.credentials)
        adapter.request(:get)
      end
    end

    context "(for SSL client auth)" do
      before do
        request.auth.ssl.cert_key_file = "spec/fixtures/client_key.pem"
        request.auth.ssl.cert_file = "spec/fixtures/client_cert.pem"
      end

      it "key, cert and verify_mode should be set" do
        net_http.expects(:cert=).with(request.auth.ssl.cert)
        net_http.expects(:key=).with(request.auth.ssl.cert_key)
        net_http.expects(:verify_mode=).with(request.auth.ssl.openssl_verify_mode)

        adapter.request(:get)
      end

      it "should set the client_ca if specified" do
        request.auth.ssl.ca_cert_file = "spec/fixtures/client_cert.pem"
        net_http.expects(:ca_file=).with(request.auth.ssl.ca_cert_file)

        adapter.request(:get)
      end

      it 'should set the ssl_version if specified' do
        request.auth.ssl.ssl_version = :SSLv3
        net_http.expects(:ssl_version=).with(request.auth.ssl.ssl_version)

        adapter.request(:get)
      end
    end
  end

  def basic_request
    request = HTTPI::Request.new "http://example.com"
    yield request if block_given?
    request
  end

end
