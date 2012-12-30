require "spec_helper"
require "httpi/adapter/em_http"
require "httpi/request"

begin
  HTTPI::Adapter.load_adapter(:em_http)

  describe HTTPI::Adapter::EmHttpRequest do

    around(:each) do |example|
      EM.synchrony do
        example.run
        EM.stop
      end
    end

    let(:adapter) { HTTPI::Adapter::EmHttpRequest.new(request) }
    let(:em_http) { EventMachine::HttpConnection.any_instance }
    let(:request) { HTTPI::Request.new("http://example.com") }

    describe "#request(:get)" do
      it "returns a valid HTTPI::Response" do
        em_http.expects(:get).
          with(:query => nil, :connect_timeout => nil, :inactivity_timeout => nil, :head => {}, :body => nil).
          returns(http_message)

        adapter.request(:get).should match_response(:body => Fixture.xml)
      end
    end

    describe "#request(:post)" do
      it "returns a valid HTTPI::Response" do
        em_http.expects(:post).
          with(:query => nil, :connect_timeout => nil, :inactivity_timeout => nil, :head => {}, :body => Fixture.xml).
          returns(http_message)

        request.body = Fixture.xml
        adapter.request(:post).should match_response(:body => Fixture.xml)
      end
    end

    describe "#request(:head)" do
      it "returns a valid HTTPI::Response" do
        em_http.expects(:head).
          with(:query => nil, :connect_timeout => nil, :inactivity_timeout => nil, :head => {}, :body => nil).
          returns(http_message)

        adapter.request(:head).should match_response(:body => Fixture.xml)
      end
    end

    describe "#request(:put)" do
      it "returns a valid HTTPI::Response" do
        em_http.expects(:put).
          with(:query => nil, :connect_timeout => nil, :inactivity_timeout => nil, :head => {}, :body => Fixture.xml).
          returns(http_message)

        request.body = Fixture.xml
        adapter.request(:put).should match_response(:body => Fixture.xml)
      end
    end

    describe "#request(:delete)" do
      it "returns a valid HTTPI::Response" do
        em_http.expects(:delete).
          with(:query => nil, :connect_timeout => nil, :inactivity_timeout => nil, :head => {}, :body => nil).
          returns(http_message(""))

        adapter.request(:delete).should match_response(:body => "")
      end
    end

    describe "#request(:custom)" do
      it "returns a valid HTTPI::Response" do
        em_http.expects(:custom).
          with(:query => nil, :connect_timeout => nil, :inactivity_timeout => nil, :head => {}, :body => nil).
          returns(http_message(""))

        adapter.request(:custom).should match_response(:body => "")
      end
    end

    describe "settings:" do
      describe "proxy" do
        before do
          request.proxy = "http://proxy-host.com:443"
          request.proxy.user = "username"
          request.proxy.password = "password"
        end

        it "sets host, port, and authorization" do
          em_http.expects(:get).once.
            with(has_entries(:proxy => { :host => "proxy-host.com", :port => 443, :authorization => %w( username password ) })).
            returns(http_message)

          adapter.request(:get)
        end
      end

      describe "connect_timeout" do
        it "is not set unless specified" do
          em_http.expects(:get).once.with(has_entries(:connect_timeout => nil)).returns(http_message)
          adapter.request(:get)
        end

        it "is set if specified" do
          request.open_timeout = 30
          em_http.expects(:get).once.with(has_entries(:connect_timeout => 30)).returns(http_message)
          adapter.request(:get)
        end
      end

      describe "receive_timeout" do
        it "is not set unless specified" do
          em_http.expects(:get).once.with(has_entries(:inactivity_timeout => nil)).returns(http_message)
          adapter.request(:get)
        end

        it "is set if specified" do
          request.read_timeout = 30
          em_http.expects(:get).once.with(has_entries(:inactivity_timeout => 30)).returns(http_message)
          adapter.request(:get)
        end
      end

      describe "set_auth" do
        it "is set for HTTP basic auth" do
          request.auth.basic "username", "password"
          em_http.expects(:get).once.with(has_entries(:head => { :authorization => %w( username password) })).returns(http_message)
          adapter.request(:get)
        end

        it "raises an error for HTTP digest auth" do
          request.auth.digest "username", "password"
          expect { adapter.request(:get) }.to raise_error
        end
      end

      context "(for SSL client auth)" do
        before do
          request.auth.ssl.cert_key_file = "spec/fixtures/client_key.pem"
          request.auth.ssl.cert_file = "spec/fixtures/client_cert.pem"
        end

        it "is not supported" do
          expect { adapter.request(:get) }.
            to raise_error(HTTPI::NotSupportedError, "EM-HTTP-Request does not support SSL client auth")
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

  end
rescue LoadError => e
  if e.message =~ /fiber/
    warn "LoadError: #{e.message} (EventMachine requires fibers)"
  else
    raise e
  end
end
