require "spec_helper"

# find out why httpi doesn't load these automatically. [dh, 2012-12-15]
unless RUBY_VERSION < "1.9"
  require "em-synchrony"
  require "em-http-request"
end
unless RUBY_PLATFORM =~ /java/
  require "curb"
end

shared_examples 'an HTTP interface' do
  let(:httpclient) { described_class::Adapter.load(:httpclient) }
  let(:net_http) { described_class::Adapter.load(:net_http) }

  before(:all) do
    described_class::Adapter::Rack.mount('example.com', IntegrationServer::Application)
    subject.log = false  # disable for specs
  end

  after(:all) do
    described_class::Adapter::Rack.unmount('example.com')
  end

  describe ".adapter=" do
    it "sets the default adapter to use" do
      described_class::Adapter.expects(:use=).with(:net_http)
      
      subject.adapter = :net_http
    end
  end

  describe ".get(request)" do
    it "executes a GET request using the default adapter" do
      request = described_class::Request.new("http://example.com")
      httpclient.any_instance.expects(:request).with(:get)

      subject.get(request)
    end
  end

  describe ".get(request, adapter)" do
    it "executes a GET request using the given adapter" do
      request = described_class::Request.new("http://example.com")
      net_http.any_instance.expects(:request).with(:get)

      subject.get(request, :net_http)
    end
  end

  describe ".get(url)" do
    it "executes a GET request using the default adapter" do
      httpclient.any_instance.expects(:request).with(:get)
      
      subject.get("http://example.com")
    end
  end

  describe ".get(url, adapter)" do
    it "executes a GET request using the given adapter" do
      net_http.any_instance.expects(:request).with(:get)
      
      subject.get("http://example.com", :net_http)
    end
  end

  describe ".post(request)" do
    it "executes a POST request using the default adapter" do
      request = described_class::Request.new("http://example.com")
      httpclient.any_instance.expects(:request).with(:post)

      subject.post(request)
    end
  end

  describe ".post(request, adapter)" do
    it "executes a POST request using the given adapter" do
      request = described_class::Request.new("http://example.com")
      net_http.any_instance.expects(:request).with(:post, anything)

      subject.post(request, :net_http)
    end
  end

  describe ".post(url, body)" do
    it "executes a POST request using the default adapter" do
      httpclient.any_instance.expects(:request).with(:post)
      
      subject.post("http://example.com", "<some>xml</some>")
    end
  end

  describe ".post(url, body, adapter)" do
    it "executes a POST request using the given adapter" do
      net_http.any_instance.expects(:request).with(:post)
      
      subject.post("http://example.com", "<some>xml</some>", :net_http)
    end
  end

  describe ".head(request)" do
    it "executes a HEAD request using the default adapter" do
      request = described_class::Request.new("http://example.com")
      httpclient.any_instance.expects(:request).with(:head, anything)

      subject.head(request)
    end
  end

  describe ".head(request, adapter)" do
    it "executes a HEAD request using the given adapter" do
      request = described_class::Request.new("http://example.com")
      net_http.any_instance.expects(:request).with(:head, anything)

      subject.head(request, :net_http)
    end
  end

  describe ".head(url)" do
    it "executes a HEAD request using the default adapter" do
      httpclient.any_instance.expects(:request).with(:head)
      
      subject.head("http://example.com")
    end
  end

  describe ".head(url, adapter)" do
    it "executes a HEAD request using the given adapter" do
      net_http.any_instance.expects(:request).with(:head)
      
      subject.head("http://example.com", :net_http)
    end
  end

  describe ".put(request)" do
    it "executes a PUT request using the default adapter" do
      request = described_class::Request.new("http://example.com")
      httpclient.any_instance.expects(:request).with(:put, anything)

      subject.put(request)
    end
  end

  describe ".put(request, adapter)" do
    it "executes a PUT request using the given adapter" do
      request = described_class::Request.new("http://example.com")
      net_http.any_instance.expects(:request).with(:put, anything)

      subject.put(request, :net_http)
    end
  end

  describe ".put(url, body)" do
    it "executes a PUT request using the default adapter" do
      httpclient.any_instance.expects(:request).with(:put)
      
      subject.put("http://example.com", "<some>xml</some>")
    end
  end

  describe ".put(url, body, adapter)" do
    it "executes a PUT request using the given adapter" do
      net_http.any_instance.expects(:request).with(:put)
      
      subject.put("http://example.com", "<some>xml</some>", :net_http)
    end
  end

  describe ".delete(request)" do
    it "executes a DELETE request using the default adapter" do
      request = described_class::Request.new("http://example.com")
      httpclient.any_instance.expects(:request).with(:delete, anything)

      subject.delete(request)
    end
  end

  describe ".delete(request, adapter)" do
    it "executes a DELETE request using the given adapter" do
      request = described_class::Request.new("http://example.com")
      net_http.any_instance.expects(:request).with(:delete, anything)

      subject.delete(request, :net_http)
    end
  end

  describe ".delete(url)" do
    it "executes a DELETE request using the default adapter" do
      httpclient.any_instance.expects(:request).with(:delete)
      
      subject.delete("http://example.com")
    end
  end

  describe ".delete(url, adapter)" do
    it "executes a DELETE request using the given adapter" do
      net_http.any_instance.expects(:request).with(:delete)
      
      subject.delete("http://example.com", :net_http)
    end
  end

  describe ".request" do
    it "allows custom HTTP methods" do
      request = described_class::Request.new("http://example.com")
      httpclient.any_instance.expects(:request).with(:custom)

      subject.request(:custom, request, :httpclient)
    end
  end

  described_class::REQUEST_METHODS.each do |method|
    describe ".#{method}" do
      let(:request) { described_class::Request.new("http://example.com") }

      it "raises an ArgumentError in case of an invalid adapter" do
        expect { subject.request method, request, :invalid }.to raise_error(ArgumentError)
      end

      described_class::Adapter::ADAPTERS.each do |adapter, opts|
        unless (adapter == :em_http && RUBY_VERSION =~ /1\.8/) || (adapter == :curb && RUBY_PLATFORM =~ /java/)
          client_class = {
            :httpclient => lambda { HTTPClient },
            :curb       => lambda { Curl::Easy },
            :net_http   => lambda { Net::HTTP },
            :em_http    => lambda { EventMachine::HttpConnection },
            :rack       => lambda { Rack::MockRequest }
          }

          context "using #{adapter}" do
            before { opts[:class].any_instance.expects(:request).with(method) }

            it "#request yields the HTTP client instance" do
              expect { |b| subject.request(method, request, adapter, &b) }.to yield_with_args(client_class[adapter].call)
            end

            it "##{method} yields the HTTP client instance" do
              expect { |b| subject.send(method, request, adapter, &b) }.to yield_with_args(client_class[adapter].call)
            end
          end
        end
      end
    end
  end

  context "(with reset)" do
    before { subject.reset_config! }

    after do
      subject.reset_config!
      subject.log = false  # disable for specs
    end

    describe ".log" do
      it "defaults to true" do
        subject.log?.should be_true
      end
    end

    describe ".logger" do
      it "defaults to Logger writing to STDOUT" do
        subject.logger.should be_a(Logger)
      end
    end

    describe ".log_level" do
      it "defaults to :debug" do
        subject.log_level.should == :debug
      end
    end

    describe ".log" do
      it "logs the given messages" do
        subject.log_level = :info
        subject.logger.expects(:info).with("Log this")
        subject.log "Log this"
      end
    end
  end

end

describe HTTPI do
  subject { described_class }
  
  it_behaves_like 'an HTTP interface'
end

describe ClientIncludedWithHTTPI do
  it_behaves_like 'an HTTP interface'
end

describe ClientExtendedWithHTTPI do
  subject { described_class }
  
  # it_behaves_like 'an HTTP interface'
  pending "Give HTTPI the ability to be extended into Modules/Classes"
end
