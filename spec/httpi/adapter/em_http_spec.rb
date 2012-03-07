require "spec_helper"
require "httpi/adapter/em_http"
require "httpi/request"

require "em-synchrony/em-http"

describe HTTPI::Adapter::HTTPClient do

  around(:each) do |example|
    EM.synchrony do
      example.run
      EM.stop
    end
  end

  let(:adapter) { HTTPI::Adapter::EmHttpRequest.new }
  let(:em_http) { EventMachine::HttpConnection.any_instance }

  describe "#get" do
    it "returns a valid HTTPI::Response" do
      em_http.expects(:get).with(:query => nil, :connect_timeout => nil, :inactivity_timeout => nil, :head => {}, :body => nil).returns(http_message)
      adapter.get(basic_request).should match_response(:body => Fixture.xml)
    end
  end

  describe "#post" do
    it "returns a valid HTTPI::Response" do
      request = HTTPI::Request.new :url => "http://example.com", :body => Fixture.xml
      em_http.expects(:post).with(:query => nil, :connect_timeout => nil, :inactivity_timeout => nil, :head => {}, :body => Fixture.xml).returns(http_message)

      adapter.post(request).should match_response(:body => Fixture.xml)
    end
  end

  describe "#head" do
    it "returns a valid HTTPI::Response" do
      em_http.expects(:head).with(:query => nil, :connect_timeout => nil, :inactivity_timeout => nil, :head => {}, :body => nil).returns(http_message)
      adapter.head(basic_request).should match_response(:body => Fixture.xml)
    end
  end

  describe "#put" do
    it "returns a valid HTTPI::Response" do
      request = HTTPI::Request.new :url => "http://example.com", :body => Fixture.xml
      em_http.expects(:put).with(:query => nil, :connect_timeout => nil, :inactivity_timeout => nil, :head => {}, :body => Fixture.xml).returns(http_message)

      adapter.put(request).should match_response(:body => Fixture.xml)
    end
  end

  describe "#delete" do
    it "returns a valid HTTPI::Response" do
      em_http.expects(:delete).with(:query => nil, :connect_timeout => nil, :inactivity_timeout => nil, :head => {}, :body => nil).returns(http_message(""))
      adapter.delete(basic_request).should match_response(:body => "")
    end
  end

  describe "settings:" do
    describe "proxy" do
      let(:proxy_request) do
        basic_request do |request|
          request.proxy = "http://proxy-host.com:443"
          request.proxy.user = "username"
          request.proxy.password = "password"
        end
      end

      it "sets host, port, and authorization" do
        em_http.expects(:get).once.with(has_entries(:proxy => { :host => "proxy-host.com", :port => 443, :authorization => %w( username password ) })).returns(http_message)
        adapter.get(proxy_request)
      end
    end

    describe "connect_timeout" do
      it "is not set unless specified" do
        request = basic_request
        em_http.expects(:get).once.with(has_entries(:connect_timeout => nil)).returns(http_message)
        adapter.get(request)
      end

      it "is set if specified" do
        request = basic_request { |request| request.open_timeout = 30 }
        em_http.expects(:get).once.with(has_entries(:connect_timeout => 30)).returns(http_message)
        adapter.get(request)
      end
    end

    describe "receive_timeout" do
      it "is not set unless specified" do
        request = basic_request
        em_http.expects(:get).once.with(has_entries(:inactivity_timeout => nil)).returns(http_message)
        adapter.get(request)
      end

      it "is set if specified" do
        request = basic_request { |request| request.read_timeout = 30 }
        em_http.expects(:get).once.with(has_entries(:inactivity_timeout => 30)).returns(http_message)
        adapter.get(request)
      end
    end

    describe "set_auth" do
      it "is set for HTTP basic auth" do
        request = basic_request { |request| request.auth.basic "username", "password" }
        em_http.expects(:get).once.with(has_entries(:head => { :authorization => %w( username password) })).returns(http_message)
        adapter.get(request)
      end

      it "raises an error for HTTP digest auth" do
        request = basic_request { |request| request.auth.digest "username", "password" }
        expect { adapter.get(request) }.to raise_error
      end
    end

    context "(for SSL client auth)" do
      let(:ssl_auth_request) do
        basic_request do |request|
          request.auth.ssl.cert_key_file = "spec/fixtures/client_key.pem"
          request.auth.ssl.cert_file = "spec/fixtures/client_cert.pem"
        end
      end

      it "client_cert, client_key and verify_mode should be set" do
        em_http.expects(:get).once.with do |options|
          key = File.read(options[:ssl][:private_key_file])
          chain = File.read(options[:ssl][:cert_chain_file])
          key == chain && chain == %w( spec/fixtures/client_key.pem spec/fixtures/client_cert.pem ).map { |file| File.read file }.map(&:chomp).join("\n")
        end.returns(http_message)
        adapter.get(ssl_auth_request)
      end
    end
  end

  def http_message(body = Fixture.xml)
    message = EventMachine::HttpClient.new("http://example.com", {})
    message.instance_variable_set :@response, body
    message.instance_variable_set :@response_header, EventMachine::HttpResponseHeader.new
    message.response_header['Accept-encoding'] = 'utf-8'
    message.response_header.http_status = '200'
    message
  end

  def basic_request
    request = HTTPI::Request.new "http://example.com"
    yield request if block_given?
    request
  end

end
