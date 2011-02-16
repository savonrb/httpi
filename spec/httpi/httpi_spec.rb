require "spec_helper"
require "httpi"

describe HTTPI do
  let(:client) { HTTPI }
  let(:default_adapter) { HTTPI::Adapter.find(HTTPI::Adapter.use)[1] }
  let(:curb) { HTTPI::Adapter.find(:curb)[1] }

  describe ".get(request)" do
    it "should execute an HTTP GET request using the default adapter" do
      request = HTTPI::Request.new
      default_adapter.any_instance.expects(:get).with(request)
      
      client.get request
    end
  end

  describe ".get(request, adapter)" do
    it "should execute an HTTP GET request using the given adapter" do
      request = HTTPI::Request.new
      curb.any_instance.expects(:get).with(request)
      
      client.get request, :curb
    end
  end

  describe ".get(url)" do
    it "should execute an HTTP GET request using the default adapter" do
      HTTPI::Request.any_instance.expects(:url=).with("http://example.com")
      default_adapter.any_instance.expects(:get).with(instance_of(HTTPI::Request))
      
      client.get "http://example.com"
    end
  end

  describe ".get(url, adapter)" do
    it "should execute an HTTP GET request using the given adapter" do
      HTTPI::Request.any_instance.expects(:url=).with("http://example.com")
      curb.any_instance.expects(:get).with(instance_of(HTTPI::Request))
      
      client.get "http://example.com", :curb
    end
  end

  describe ".post(request)" do
    it "should execute an HTTP POST request using the default adapter" do
      request = HTTPI::Request.new
      default_adapter.any_instance.expects(:post).with(request)
      
      client.post request
    end
  end

  describe ".post(request, adapter)" do
    it "should execute an HTTP POST request using the given adapter" do
      request = HTTPI::Request.new
      curb.any_instance.expects(:post).with(request)
      
      client.post request, :curb
    end
  end

  describe ".post(url, body)" do
    it "should execute an HTTP POST request using the default adapter" do
      HTTPI::Request.any_instance.expects(:url=).with("http://example.com")
      HTTPI::Request.any_instance.expects(:body=).with("<some>xml</some>")
      default_adapter.any_instance.expects(:post).with(instance_of(HTTPI::Request))
      
      client.post "http://example.com", "<some>xml</some>"
    end
  end

  describe ".post(url, body, adapter)" do
    it "should execute an HTTP POST request using the given adapter" do
      HTTPI::Request.any_instance.expects(:url=).with("http://example.com")
      HTTPI::Request.any_instance.expects(:body=).with("<some>xml</some>")
      curb.any_instance.expects(:post).with(instance_of(HTTPI::Request))
      
      client.post "http://example.com", "<some>xml</some>", :curb
    end
  end

  describe ".head(request)" do
    it "should execute an HTTP HEAD request using the default adapter" do
      request = HTTPI::Request.new
      default_adapter.any_instance.expects(:head).with(request)
      
      client.head request
    end
  end

  describe ".head(request, adapter)" do
    it "should execute an HTTP HEAD request using the given adapter" do
      request = HTTPI::Request.new
      curb.any_instance.expects(:head).with(request)
      
      client.head request, :curb
    end
  end

  describe ".head(url)" do
    it "should execute an HTTP HEAD request using the default adapter" do
      HTTPI::Request.any_instance.expects(:url=).with("http://example.com")
      default_adapter.any_instance.expects(:head).with(instance_of(HTTPI::Request))
      
      client.head "http://example.com"
    end
  end

  describe ".head(url, adapter)" do
    it "should execute an HTTP HEAD request using the given adapter" do
      HTTPI::Request.any_instance.expects(:url=).with("http://example.com")
      curb.any_instance.expects(:head).with(instance_of(HTTPI::Request))
      
      client.head "http://example.com", :curb
    end
  end

  describe ".put(request)" do
    it "should execute an HTTP PUT request using the default adapter" do
      request = HTTPI::Request.new
      default_adapter.any_instance.expects(:put).with(request)
      
      client.put request
    end
  end

  describe ".put(request, adapter)" do
    it "should execute an HTTP PUT request using the given adapter" do
      request = HTTPI::Request.new
      curb.any_instance.expects(:put).with(request)
      
      client.put request, :curb
    end
  end

  describe ".put(url, body)" do
    it "should execute an HTTP PUT request using the default adapter" do
      HTTPI::Request.any_instance.expects(:url=).with("http://example.com")
      HTTPI::Request.any_instance.expects(:body=).with("<some>xml</some>")
      default_adapter.any_instance.expects(:put).with(instance_of(HTTPI::Request))
      
      client.put "http://example.com", "<some>xml</some>"
    end
  end

  describe ".put(url, body, adapter)" do
    it "should execute an HTTP PUT request using the given adapter" do
      HTTPI::Request.any_instance.expects(:url=).with("http://example.com")
      HTTPI::Request.any_instance.expects(:body=).with("<some>xml</some>")
      curb.any_instance.expects(:put).with(instance_of(HTTPI::Request))
      
      client.put "http://example.com", "<some>xml</some>", :curb
    end
  end

  describe ".delete(request)" do
    it "should execute an HTTP DELETE request using the default adapter" do
      request = HTTPI::Request.new
      default_adapter.any_instance.expects(:delete).with(request)
      
      client.delete request
    end
  end

  describe ".delete(request, adapter)" do
    it "should execute an HTTP DELETE request using the given adapter" do
      request = HTTPI::Request.new
      curb.any_instance.expects(:delete).with(request)
      
      client.delete request, :curb
    end
  end

  describe ".delete(url)" do
    it "should execute an HTTP DELETE request using the default adapter" do
      HTTPI::Request.any_instance.expects(:url=).with("http://example.com")
      default_adapter.any_instance.expects(:delete).with(instance_of(HTTPI::Request))
      
      client.delete "http://example.com"
    end
  end

  describe ".delete(url, adapter)" do
    it "should execute an HTTP DELETE request using the given adapter" do
      HTTPI::Request.any_instance.expects(:url=).with("http://example.com")
      curb.any_instance.expects(:delete).with(instance_of(HTTPI::Request))
      
      client.delete "http://example.com", :curb
    end
  end

  describe ".request" do
    it "should raise an ArgumentError in case of an invalid request method" do
      lambda { client.request :invalid, HTTPI::Request.new }.should raise_error(ArgumentError)
    end
  end

  HTTPI::REQUEST_METHODS.each do |method|
    describe ".request(#{method}, request, adapter)" do
      it "should delegate to the .#{method} method" do
        HTTPI.expects(method)
        client.request method, HTTPI::Request.new
      end
    end

    describe ".#{method}" do
      let(:request) { HTTPI::Request.new :url => "http://example.com" }

      it "should raise an ArgumentError in case of an invalid adapter" do
        lambda { client.request method, request, :invalid }.should raise_error(ArgumentError)
      end

      it "should raise an ArgumentError in case of an invalid request" do
        lambda { client.request method, "invalid" }.should raise_error(ArgumentError)
      end

      HTTPI::Adapter.adapters.each do |adapter, values|
        client_class = {
          :httpclient => lambda { HTTPClient },
          :curb       => lambda { Curl::Easy },
          :net_http   => lambda { Net::HTTP }
        }

        context "using #{adapter}" do
          before { values[:class].any_instance.expects(method) }

          it "should log that we're executing an HTTP request" do
            HTTPI.expects(:log).with("HTTPI executes HTTP #{method.to_s.upcase} using the #{adapter} adapter")
            client.request method, request, adapter
          end

          it "should yield the HTTP client instance used for the request" do
            block = lambda { |http| http.should be_a(client_class[adapter].call) }
            client.request(method, request, adapter, &block)
          end
        end
      end

      HTTPI::Adapter.adapters.reject { |key, value| key == HTTPI::Adapter::FALLBACK }.each do |adapter, values|
        context "when #{adapter} could not be loaded" do
          before do
            HTTPI::Adapter.expects(:require).with(values[:require]).raises(LoadError)
            HTTPI::Adapter.expects(:require).with("net/https")
            HTTPI::Adapter::NetHTTP.any_instance.expects(method)
          end

          it "should fall back to using the FALLBACK adapter" do
            HTTPI.expects(:log).with(
              "HTTPI tried to use the #{adapter} adapter, but was unable to find the library in the LOAD_PATH.",
              "Falling back to using the #{HTTPI::Adapter::FALLBACK} adapter now."
            )
            HTTPI.expects(:log).with("HTTPI executes HTTP #{method.to_s.upcase} using the #{HTTPI::Adapter::FALLBACK} adapter")
            
            client.request method, request, adapter
          end
        end
      end
    end
  end

  context "with resetting the defaults" do
    before { HTTPI.reset_config! }

    after do
      HTTPI.reset_config!
      HTTPI.log = false  # disable for specs
    end

    describe ".log" do
      it "should default to true" do
        HTTPI.log?.should be_true
      end

      it "should set whether to log" do
        HTTPI.log = false
        HTTPI.log?.should be_false
      end
    end

    describe ".logger" do
      it "should default to Logger writing to STDOUT" do
        HTTPI.logger.should be_a(Logger)
      end

      it "should set the logger to use" do
        MyLogger = Class.new
        HTTPI.logger = MyLogger
        HTTPI.logger.should == MyLogger
      end
    end

    describe ".log_level" do
      it "should default to :warn" do
        HTTPI.log_level.should == :warn
      end

      it "should set the log level to use" do
        HTTPI.log_level = :info
        HTTPI.log_level.should == :info
      end
    end

    describe ".log" do
      it "should log given messages" do
        HTTPI.log_level = :debug
        HTTPI.logger.expects(:debug).with("Log this")
        HTTPI.log "Log", "this"
      end
    end
  end

end
