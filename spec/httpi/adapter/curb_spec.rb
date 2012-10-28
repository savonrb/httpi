require "spec_helper"
require "httpi/adapter/curb"
require "httpi/request"

# curb does not run on jruby
unless RUBY_PLATFORM =~ /java/
  HTTPI::Adapter.load_adapter(:curb)

  describe HTTPI::Adapter::Curb do

    let(:adapter) { HTTPI::Adapter::Curb.new(request) }
    let(:curb)    { Curl::Easy.any_instance }
    let(:request) { HTTPI::Request.new("http://example.com") }

    describe "#request(:get)" do
      before do
        curb.expects(:http_get)
        curb.expects(:response_code).returns(200)
        curb.expects(:header_str).returns("Accept-encoding: utf-8")
        curb.expects(:body_str).returns(Fixture.xml)
      end

      it "returns a valid HTTPI::Response" do
        adapter.request(:get).should match_response(:body => Fixture.xml)
      end
    end

    describe "#request(:post)" do
      before do
        curb.expects(:http_post)
        curb.expects(:response_code).returns(200)
        curb.expects(:header_str).returns("Accept-encoding: utf-8")
        curb.expects(:body_str).returns(Fixture.xml)
      end

      it "returns a valid HTTPI::Response" do
        adapter.request(:post).should match_response(:body => Fixture.xml)
      end
    end

    describe "#request(:post)" do
      it "sends the body in the request" do
        curb.expects(:http_post).with("xml=hi&name=123")

        request.body = "xml=hi&name=123"
        adapter.request(:post)
      end
    end

    describe "#request(:head)" do
      before do
        curb.expects(:http_head)
        curb.expects(:response_code).returns(200)
        curb.expects(:header_str).returns("Accept-encoding: utf-8")
        curb.expects(:body_str).returns(Fixture.xml)
      end

      it "returns a valid HTTPI::Response" do
        adapter.request(:head).should match_response(:body => Fixture.xml)
      end
    end

    describe "#request(:put)" do
      before do
        curb.expects(:http_put)
        curb.expects(:response_code).returns(200)
        curb.expects(:header_str).returns("Accept-encoding: utf-8")
        curb.expects(:body_str).returns(Fixture.xml)
      end

      it "returns a valid HTTPI::Response" do
        adapter.request(:put).should match_response(:body => Fixture.xml)
      end
    end

    describe "#request(:put)" do
      it "sends the body in the request" do
        curb.expects(:http_put).with('xml=hi&name=123')

        request.body = 'xml=hi&name=123'
        adapter.request(:put)
      end
    end

    describe "#request(:delete)" do
      before do
        curb.expects(:http_delete)
        curb.expects(:response_code).returns(200)
        curb.expects(:header_str).returns("Accept-encoding: utf-8")
        curb.expects(:body_str).returns("")
      end

      it "returns a valid HTTPI::Response" do
        adapter.request(:delete).should match_response(:body => "")
      end
    end

    describe "#request(:custom)" do
      it "raises a NotSupportedError" do
        expect { adapter.request(:custom) }.
          to raise_error(HTTPI::NotSupportedError, "Curb does not support custom HTTP methods")
      end
    end

    describe "settings:" do
      before { curb.stubs(:http_get) }

      describe "url" do
        it "always sets the request url" do
          curb.expects(:url=).with(request.url.to_s)
          adapter.request(:get)
        end
      end

      describe "proxy_url" do
        it "is not set unless it's specified" do
          curb.expects(:proxy_url=).never
          adapter.request(:get)
        end

        it "is set if specified" do
          request.proxy = "http://proxy.example.com"
          curb.expects(:proxy_url=).with(request.proxy.to_s)

          adapter.request(:get)
        end
      end

      describe "timeout" do
        it "is not set unless it's specified" do
          curb.expects(:timeout=).never
          adapter.request(:get)
        end

        it "is set if specified" do
          request.read_timeout = 30
          curb.expects(:timeout=).with(request.read_timeout)

          adapter.request(:get)
        end
      end

      describe "connect_timeout" do
        it "is not set unless it's specified" do
          curb.expects(:connect_timeout=).never
          adapter.request(:get)
        end

        it "is set if specified" do
          request.open_timeout = 30
          curb.expects(:connect_timeout=).with(30)

          adapter.request(:get)
        end
      end

      describe "headers" do
        it "is always set" do
          curb.expects(:headers=).with({})
          adapter.request(:get)
        end
      end

      describe "verbose" do
        it "is always set to false" do
          curb.expects(:verbose=).with(false)
          adapter.request(:get)
        end
      end

      describe "http_auth_types" do
        it "is set to :basic for HTTP basic auth" do
          request.auth.basic "username", "password"
          curb.expects(:http_auth_types=).with(:basic)

          adapter.request(:get)
        end

        it "is set to :digest for HTTP digest auth" do
          request.auth.digest "username", "password"
          curb.expects(:http_auth_types=).with(:digest)

          adapter.request(:get)
        end

        it "is set to :gssnegotiate for HTTP Negotiate auth" do
          request.auth.gssnegotiate
          curb.expects(:http_auth_types=).with(:gssnegotiate)

          adapter.request(:get)
        end
      end

      describe "username and password" do
        it "is set for HTTP basic auth" do
          request.auth.basic "username", "password"

          curb.expects(:username=).with("username")
          curb.expects(:password=).with("password")
          adapter.request(:get)
        end

        it "is set for HTTP digest auth" do
          request.auth.digest "username", "password"

          curb.expects(:username=).with("username")
          curb.expects(:password=).with("password")
          adapter.request(:get)
        end
      end

      context "(for SSL client auth)" do
        let(:request) do
          request = HTTPI::Request.new("http://example.com")
          request.auth.ssl.cert_key_file = "spec/fixtures/client_key.pem"
          request.auth.ssl.cert_file = "spec/fixtures/client_cert.pem"
          request
        end

        it "cert_key, cert and ssl_verify_peer should be set" do
          curb.expects(:cert_key=).with(request.auth.ssl.cert_key_file)
          curb.expects(:cert=).with(request.auth.ssl.cert_file)
          curb.expects(:ssl_verify_peer=).with(true)
          curb.expects(:certtype=).with(request.auth.ssl.cert_type.to_s.upcase)

          adapter.request(:get)
        end

        it "sets the cert_type to DER if specified" do
          request.auth.ssl.cert_type = :der
          curb.expects(:certtype=).with(:der.to_s.upcase)

          adapter.request(:get)
        end

        it "raise if an invalid cert type was set" do
          expect { request.auth.ssl.cert_type = :invalid }.
            to raise_error(ArgumentError, "Invalid SSL cert type :invalid\nPlease specify one of [:pem, :der]")
        end

        it "sets the cacert if specified" do
          request.auth.ssl.ca_cert_file = "spec/fixtures/client_cert.pem"
          curb.expects(:cacert=).with(request.auth.ssl.ca_cert_file)

          adapter.request(:get)
        end

        context 'sets ssl_version' do
          it 'defaults to nil when no ssl_version is specified' do
            curb.expects(:ssl_version=).with(nil)
            adapter.request(:get)
          end

          it 'to 1 when ssl_version is specified as TLSv1' do
            request.auth.ssl.ssl_version = :TLSv1
            curb.expects(:ssl_version=).with(1)

            adapter.request(:get)
          end

          it 'to 2 when ssl_version is specified as SSLv2' do
            request.auth.ssl.ssl_version = :SSLv2
            curb.expects(:ssl_version=).with(2)

            adapter.request(:get)
          end

          it 'to 3 when ssl_version is specified as SSLv3' do
            request.auth.ssl.ssl_version = :SSLv3
            curb.expects(:ssl_version=).with(3)

            adapter.request(:get)
          end
        end
      end
    end

  end
end
