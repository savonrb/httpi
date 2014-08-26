require "spec_helper"
require "integration/support/server"

# find out why httpi doesn't load these automatically. [dh, 2012-12-15]
require "excon"
require "net/http/persistent"

unless RUBY_VERSION < "1.9"
  require "em-synchrony"
  require "em-http-request"
end
unless RUBY_PLATFORM =~ /java/
  require "curb"
end

describe HTTPI do
  let(:client) { HTTPI }
  let(:httpclient) { HTTPI::Adapter.load(:httpclient) }
  let(:net_http) { HTTPI::Adapter.load(:net_http) }
  let(:net_http_persistent) { HTTPI::Adapter.load(:net_http_persistent) }

  before(:all) do
    HTTPI::Adapter::Rack.mount('example.com', IntegrationServer::Application)
  end

  after(:all) do
    HTTPI::Adapter::Rack.unmount('example.com')
  end

  describe ".adapter=" do
    it "sets the default adapter to use" do
      HTTPI::Adapter.expects(:use=).with(:net_http)
      HTTPI.adapter = :net_http
    end
  end

  describe ".query_builder" do
    it "gets flat builder by default" do
      expect(client.query_builder).to eq(HTTPI::QueryBuilder::Flat)
    end
    context "setter" do
      after { client.query_builder = HTTPI::QueryBuilder::Flat }
      it "looks up for class if symbol" do
        client.query_builder = :nested
        expect(client.query_builder).to eq(HTTPI::QueryBuilder::Nested)
      end
      it "validates if symbol is a valid option" do
        expect do
          client.query_builder = :xxx
        end.to raise_error(ArgumentError)
      end
      it "validates if value respond to build" do
        expect do
          client.query_builder = nil
        end.to raise_error(ArgumentError)
      end
      it "accepts valid class" do
        client.query_builder = HTTPI::QueryBuilder::Nested
        expect(client.query_builder).to eq(HTTPI::QueryBuilder::Nested)
      end
    end
  end

  describe ".get(request)" do
    it "executes a GET request using the default adapter" do
      request = HTTPI::Request.new("http://example.com")
      httpclient.any_instance.expects(:request).with(:get)

      client.get(request)
    end
  end

  describe ".get(request, adapter)" do
    it "executes a GET request using the given adapter" do
      request = HTTPI::Request.new("http://example.com")
      net_http.any_instance.expects(:request).with(:get)

      client.get(request, :net_http)
    end
  end

  describe ".get(url)" do
    it "executes a GET request using the default adapter" do
      httpclient.any_instance.expects(:request).with(:get)
      client.get("http://example.com")
    end
  end

  describe ".get(url, adapter)" do
    it "executes a GET request using the given adapter" do
      net_http.any_instance.expects(:request).with(:get)
      client.get("http://example.com", :net_http)
    end
  end

  describe ".post(request)" do
    it "executes a POST request using the default adapter" do
      request = HTTPI::Request.new("http://example.com")
      httpclient.any_instance.expects(:request).with(:post)

      client.post(request)
    end
  end

  describe ".post(request, adapter)" do
    it "executes a POST request using the given adapter" do
      request = HTTPI::Request.new("http://example.com")
      net_http.any_instance.expects(:request).with(:post, anything)

      client.post(request, :net_http)
    end
  end

  describe ".post(url, body)" do
    it "executes a POST request using the default adapter" do
      httpclient.any_instance.expects(:request).with(:post)
      client.post("http://example.com", "<some>xml</some>")
    end
  end

  describe ".post(url, body, adapter)" do
    it "executes a POST request using the given adapter" do
      net_http.any_instance.expects(:request).with(:post)
      client.post("http://example.com", "<some>xml</some>", :net_http)
    end
  end

  describe ".head(request)" do
    it "executes a HEAD request using the default adapter" do
      request = HTTPI::Request.new("http://example.com")
      httpclient.any_instance.expects(:request).with(:head, anything)

      client.head(request)
    end
  end

  describe ".head(request, adapter)" do
    it "executes a HEAD request using the given adapter" do
      request = HTTPI::Request.new("http://example.com")
      net_http.any_instance.expects(:request).with(:head, anything)

      client.head(request, :net_http)
    end
  end

  describe ".head(url)" do
    it "executes a HEAD request using the default adapter" do
      httpclient.any_instance.expects(:request).with(:head)
      client.head("http://example.com")
    end
  end

  describe ".head(url, adapter)" do
    it "executes a HEAD request using the given adapter" do
      net_http.any_instance.expects(:request).with(:head)
      client.head("http://example.com", :net_http)
    end
  end

  describe ".put(request)" do
    it "executes a PUT request using the default adapter" do
      request = HTTPI::Request.new("http://example.com")
      httpclient.any_instance.expects(:request).with(:put, anything)

      client.put(request)
    end
  end

  describe ".put(request, adapter)" do
    it "executes a PUT request using the given adapter" do
      request = HTTPI::Request.new("http://example.com")
      net_http.any_instance.expects(:request).with(:put, anything)

      client.put(request, :net_http)
    end
  end

  describe ".put(url, body)" do
    it "executes a PUT request using the default adapter" do
      httpclient.any_instance.expects(:request).with(:put)
      client.put("http://example.com", "<some>xml</some>")
    end
  end

  describe ".put(url, body, adapter)" do
    it "executes a PUT request using the given adapter" do
      net_http.any_instance.expects(:request).with(:put)
      client.put("http://example.com", "<some>xml</some>", :net_http)
    end
  end

  describe ".delete(request)" do
    it "executes a DELETE request using the default adapter" do
      request = HTTPI::Request.new("http://example.com")
      httpclient.any_instance.expects(:request).with(:delete, anything)

      client.delete(request)
    end
  end

  describe ".delete(request, adapter)" do
    it "executes a DELETE request using the given adapter" do
      request = HTTPI::Request.new("http://example.com")
      net_http.any_instance.expects(:request).with(:delete, anything)

      client.delete(request, :net_http)
    end
  end

  describe ".delete(url)" do
    it "executes a DELETE request using the default adapter" do
      httpclient.any_instance.expects(:request).with(:delete)
      client.delete("http://example.com")
    end
  end

  describe ".delete(url, adapter)" do
    it "executes a DELETE request using the given adapter" do
      net_http.any_instance.expects(:request).with(:delete)
      client.delete("http://example.com", :net_http)
    end
  end

  describe ".request" do
    let(:request) { HTTPI::Request.new('http://example.com') }

    it "allows custom HTTP methods" do
      httpclient.any_instance.expects(:request).with(:custom)

      client.request(:custom, request, :httpclient)
    end

    it 'follows redirects' do
      request.follow_redirect = true
      redirect_location = 'http://foo.bar'

      redirect = HTTPI::Response.new(302, {'location' => redirect_location}, 'Moved')
      response = HTTPI::Response.new(200, {}, 'success')

      httpclient.any_instance.expects(:request).twice.with(:custom).returns(redirect, response)
      request.expects(:url=).with(redirect_location)

      client.request(:custom, request, :httpclient)
    end
  end

  HTTPI::REQUEST_METHODS.each do |method|
    describe ".#{method}" do
      let(:request) { HTTPI::Request.new("http://example.com") }

      it "raises an ArgumentError in case of an invalid adapter" do
        expect { client.request method, request, :invalid }.to raise_error(ArgumentError)
      end

      HTTPI::Adapter::ADAPTERS.each do |adapter, opts|
        unless (adapter == :em_http && RUBY_VERSION =~ /1\.8/) || (adapter == :curb && RUBY_PLATFORM =~ /java/)
          client_class = {
            :httpclient => lambda { HTTPClient },
            :curb       => lambda { Curl::Easy },
            :net_http   => lambda { Net::HTTP },
            :net_http_persistent => lambda { Net::HTTP::Persistent },
            :em_http    => lambda { EventMachine::HttpConnection },
            :rack       => lambda { Rack::MockRequest },
            :excon      => lambda { Excon::Connection }
          }

          context "using #{adapter}" do
            before { opts[:class].any_instance.expects(:request).with(method) }

            it "#request yields the HTTP client instance" do
              expect { |b| client.request(method, request, adapter, &b) }.to yield_with_args(client_class[adapter].call)
            end

            it "##{method} yields the HTTP client instance" do
              expect { |b| client.send(method, request, adapter, &b) }.to yield_with_args(client_class[adapter].call)
            end
          end
        end
      end
    end
  end

  context "(with reset)" do
    before { HTTPI.reset_config! }

    after do
      HTTPI.reset_config!
      HTTPI.log = false  # disable for specs
    end

    describe ".log" do
      it "defaults to true" do
        expect(HTTPI.log?).to be_truthy
      end
    end

    describe ".logger" do
      it "defaults to Logger writing to STDOUT" do
        expect(HTTPI.logger).to be_a(Logger)
      end
    end

    describe ".log_level" do
      it "defaults to :debug" do
        expect(HTTPI.log_level).to eq(:debug)
      end
    end

    describe ".log" do
      it "logs the given messages" do
        HTTPI.log_level = :info
        HTTPI.logger.expects(:info).with("Log this")
        HTTPI.log "Log this"
      end
    end
  end

end
