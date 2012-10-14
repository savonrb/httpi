require "spec_helper"
require "httpi"

describe HTTPI do
  let(:client) { HTTPI }
  let(:httpclient) { HTTPI::Adapter.load(:httpclient)[1] }
  let(:net_http) { HTTPI::Adapter.load(:net_http)[1] }

  describe ".get(request)" do
    it "executes a GET request using the default adapter" do
      request = HTTPI::Request.new("http://example.com")
      httpclient.any_instance.expects(:get).with(request)

      client.get request
    end
  end

  describe ".get(request, adapter)" do
    it "executes a GET request using the given adapter" do
      request = HTTPI::Request.new("http://example.com")
      net_http.any_instance.expects(:get).with(request)

      client.get request, :net_http
    end
  end

  describe ".get(url)" do
    it "executes a GET request using the default adapter" do
      httpclient.any_instance.expects(:get).with do |request|
        request.should be_a(HTTPI::Request)
        request.url.should == URI("http://example.com")
      end

      client.get "http://example.com"
    end
  end

  describe ".get(url, adapter)" do
    it "executes a GET request using the given adapter" do
      net_http.any_instance.expects(:get).with do |request|
        request.should be_a(HTTPI::Request)
        request.url.should == URI("http://example.com")
      end

      client.get "http://example.com", :net_http
    end
  end

  describe ".post(request)" do
    it "executes a POST request using the default adapter" do
      request = HTTPI::Request.new("http://example.com")
      httpclient.any_instance.expects(:post).with(request)

      client.post request
    end
  end

  describe ".post(request, adapter)" do
    it "executes a POST request using the given adapter" do
      request = HTTPI::Request.new("http://example.com")
      net_http.any_instance.expects(:post).with(request)

      client.post request, :net_http
    end
  end

  describe ".post(url, body)" do
    it "executes a POST request using the default adapter" do
      httpclient.any_instance.expects(:post).with do |request|
        request.should be_a(HTTPI::Request)
        request.url.should == URI("http://example.com")
        request.body.should == "<some>xml</some>"
      end

      client.post "http://example.com", "<some>xml</some>"
    end
  end

  describe ".post(url, body, adapter)" do
    it "executes a POST request using the given adapter" do
      net_http.any_instance.expects(:post).with do |request|
        request.should be_a(HTTPI::Request)
        request.url.should == URI("http://example.com")
        request.body.should == "<some>xml</some>"
      end

      client.post "http://example.com", "<some>xml</some>", :net_http
    end
  end

  describe ".head(request)" do
    it "executes a HEAD request using the default adapter" do
      request = HTTPI::Request.new("http://example.com")
      httpclient.any_instance.expects(:head).with(request)

      client.head request
    end
  end

  describe ".head(request, adapter)" do
    it "executes a HEAD request using the given adapter" do
      request = HTTPI::Request.new("http://example.com")
      net_http.any_instance.expects(:head).with(request)

      client.head request, :net_http
    end
  end

  describe ".head(url)" do
    it "executes a HEAD request using the default adapter" do
      httpclient.any_instance.expects(:head).with do |request|
        request.should be_a(HTTPI::Request)
        request.url.should == URI("http://example.com")
      end

      client.head "http://example.com"
    end
  end

  describe ".head(url, adapter)" do
    it "executes a HEAD request using the given adapter" do
      net_http.any_instance.expects(:head).with do |request|
        request.should be_a(HTTPI::Request)
        request.url.should == URI("http://example.com")
      end

      client.head "http://example.com", :net_http
    end
  end

  describe ".put(request)" do
    it "executes a PUT request using the default adapter" do
      request = HTTPI::Request.new("http://example.com")
      httpclient.any_instance.expects(:put).with(request)

      client.put request
    end
  end

  describe ".put(request, adapter)" do
    it "executes a PUT request using the given adapter" do
      request = HTTPI::Request.new("http://example.com")
      net_http.any_instance.expects(:put).with(request)

      client.put request, :net_http
    end
  end

  describe ".put(url, body)" do
    it "executes a PUT request using the default adapter" do
      httpclient.any_instance.expects(:put).with do |request|
        request.should be_a(HTTPI::Request)
        request.url.should == URI("http://example.com")
        request.body.should == "<some>xml</some>"
      end

      client.put "http://example.com", "<some>xml</some>"
    end
  end

  describe ".put(url, body, adapter)" do
    it "executes a PUT request using the given adapter" do
      net_http.any_instance.expects(:put).with do |request|
        request.should be_a(HTTPI::Request)
        request.url.should == URI("http://example.com")
        request.body.should == "<some>xml</some>"
      end

      client.put "http://example.com", "<some>xml</some>", :net_http
    end
  end

  describe ".delete(request)" do
    it "executes a DELETE request using the default adapter" do
      request = HTTPI::Request.new("http://example.com")
      httpclient.any_instance.expects(:delete).with(request)

      client.delete request
    end
  end

  describe ".delete(request, adapter)" do
    it "executes a DELETE request using the given adapter" do
      request = HTTPI::Request.new("http://example.com")
      net_http.any_instance.expects(:delete).with(request)

      client.delete request, :net_http
    end
  end

  describe ".delete(url)" do
    it "executes a DELETE request using the default adapter" do
      httpclient.any_instance.expects(:delete).with do |request|
        request.should be_a(HTTPI::Request)
        request.url.should == URI("http://example.com")
      end

      client.delete "http://example.com"
    end
  end

  describe ".delete(url, adapter)" do
    it "executes a DELETE request using the given adapter" do
      net_http.any_instance.expects(:delete).with do |request|
        request.should be_a(HTTPI::Request)
        request.url.should == URI("http://example.com")
      end

      client.delete "http://example.com", :net_http
    end
  end

  describe ".request" do
    it "raises an ArgumentError in case of an invalid request method" do
      expect { client.request :invalid, HTTPI::Request.new }.to raise_error(ArgumentError)
    end
  end

  describe ".adapter=" do
    it "sets the default adapter to use" do
      HTTPI::Adapter.expects(:use=).with(:net_http)
      HTTPI.adapter = :net_http
    end
  end

  HTTPI::REQUEST_METHODS.each do |method|
    describe ".request(#{method}, request, adapter)" do
      it "delegates to the .#{method} method" do
        HTTPI.expects(method)
        client.request method, HTTPI::Request.new("http://example.com")
      end
    end

    describe ".#{method}" do
      let(:request) { HTTPI::Request.new :url => "http://example.com" }

      it "raises an ArgumentError in case of an invalid adapter" do
        expect { client.request method, request, :invalid }.to raise_error(ArgumentError)
      end

      it "raises an ArgumentError in case of an invalid request" do
        expect { client.request method, "invalid" }.to raise_error(ArgumentError)
      end

      HTTPI::Adapter::ADAPTERS.each do |adapter, opts|
        unless (adapter == :em_http && RUBY_VERSION =~ /1\.8/) || (adapter == :curb && RUBY_PLATFORM =~ /java/)
          client_class = {
            :httpclient => lambda { HTTPClient },
            :curb       => lambda { Curl::Easy },
            :net_http   => lambda { Net::HTTP },
            :em_http    => Object  # TODO: FIX ME
          }

          context "using #{adapter}" do
            before { opts[:class].any_instance.expects(method) }

            it "logs that we're executing a request" do
              HTTPI.expects(:log).with("HTTPI executes HTTP #{method.to_s.upcase} using the #{adapter} adapter")
              client.request method, request, adapter
            end

            it "yields the HTTP client instance used for the request" do
              block = lambda { |http| http.be_a(client_class[adapter].call) }
              client.request(method, request, adapter, &block)
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
        HTTPI.log?.should be_true
      end
    end

    describe ".logger" do
      it "defaults to Logger writing to STDOUT" do
        HTTPI.logger.should be_a(Logger)
      end
    end

    describe ".log_level" do
      it "defaults to :debug" do
        HTTPI.log_level.should == :debug
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
