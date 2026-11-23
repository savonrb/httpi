require "spec_helper"
require "httpi/adapter/em_http"
require "httpi/request"

if EM_HTTP_AVAILABLE
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
        em_http.expects(:get)
          .with(query: nil, head: {}, body: nil)
          .returns(http_message)

        expect(adapter.request(:get)).to match_response(body: Fixture.xml)
      end
    end

    describe "#request(:post)" do
      it "returns a valid HTTPI::Response" do
        em_http.expects(:post)
          .with(query: nil, head: {}, body: Fixture.xml)
          .returns(http_message)

        request.body = Fixture.xml
        expect(adapter.request(:post)).to match_response(body: Fixture.xml)
      end
    end

    describe "#request(:head)" do
      it "returns a valid HTTPI::Response" do
        em_http.expects(:head)
          .with(query: nil, head: {}, body: nil)
          .returns(http_message)

        expect(adapter.request(:head)).to match_response(body: Fixture.xml)
      end
    end

    describe "#request(:put)" do
      it "returns a valid HTTPI::Response" do
        em_http.expects(:put)
          .with(query: nil, head: {}, body: Fixture.xml)
          .returns(http_message)

        request.body = Fixture.xml
        expect(adapter.request(:put)).to match_response(body: Fixture.xml)
      end
    end

    describe "#request(:delete)" do
      it "returns a valid HTTPI::Response" do
        em_http.expects(:delete)
          .with(query: nil, head: {}, body: nil)
          .returns(http_message(""))

        expect(adapter.request(:delete)).to match_response(body: "")
      end
    end

    describe "#request(:custom)" do
      it "returns a valid HTTPI::Response" do
        em_http.expects(:custom)
          .with(query: nil, head: {}, body: nil)
          .returns(http_message(""))

        expect(adapter.request(:custom)).to match_response(body: "")
      end
    end

    describe "settings:" do
      describe "proxy" do
        before do
          request.proxy = "http://proxy-host.com:443"
          request.proxy.user = "username"
          request.proxy.password = "password"
        end

        it "sets host, port and authorization" do
          url = "http://example.com:80"
          connection_options = {
            proxy: {
              host: "proxy-host.com",
              port: 443,
              authorization: ["username", "password"]
            }
          }

          EventMachine::HttpRequest.expects(:new).with(url, connection_options)

          adapter
        end
      end

      describe "connect_timeout" do
        it "is passed as a connection option" do
          request.open_timeout = 30

          url = "http://example.com:80"
          connection_options = {connect_timeout: 30}

          EventMachine::HttpRequest.expects(:new).with(url, connection_options)

          adapter
        end
      end

      describe "receive_timeout" do
        it "is passed as a connection option (when read_timeout specified)" do
          request.read_timeout = 60

          url = "http://example.com:80"
          connection_options = {inactivity_timeout: 60}

          EventMachine::HttpRequest.expects(:new).with(url, connection_options)

          adapter
        end

        it "is passed as a connection option (when write_timeout specified)" do
          request.write_timeout = 60

          url = "http://example.com:80"
          connection_options = {inactivity_timeout: 60}

          EventMachine::HttpRequest.expects(:new).with(url, connection_options)

          adapter
        end
      end

      describe "set_auth" do
        it "is set for HTTP basic auth" do
          request.auth.basic "username", "password"
          em_http.expects(:get).once.with(has_entries(head: {authorization: %w[username password]})).returns(http_message)
          adapter.request(:get)
        end

        it "raises an error for HTTP digest auth" do
          request.auth.digest "username", "password"
          expect { adapter.request(:get) }.to raise_error HTTPI::NotSupportedError
        end
      end

      context "(for SSL client auth)" do
        before do
          request.auth.ssl.cert_key_file = "spec/fixtures/client_key.pem"
          request.auth.ssl.cert_file = "spec/fixtures/client_cert.pem"
        end

        it "is not supported" do
          expect { adapter.request(:get) }
            .to raise_error(HTTPI::NotSupportedError, "EM-HTTP-Request does not support SSL client auth")
        end
      end

      context "(for HTTPS requests)" do
        let(:request) { HTTPI::Request.new("https://example.com") }
        let(:verification_error) do
          "EM-HTTP-Request cannot verify TLS certificates. " \
            "Use another adapter, or set verify_mode to :none to skip verification"
        end

        it "refuses to send the request with the default verify_mode" do
          em_http.expects(:get).never

          expect { adapter.request(:get) }
            .to raise_error(HTTPI::NotSupportedError, verification_error)
        end

        it "refuses to send the request when verify_mode is explicitly :peer" do
          request.auth.ssl.verify_mode = :peer
          em_http.expects(:get).never

          expect { adapter.request(:get) }
            .to raise_error(HTTPI::NotSupportedError, verification_error)
        end

        it "sends the request without verification when verify_mode is :none" do
          request.auth.ssl.verify_mode = :none
          em_http.expects(:get).returns(http_message)

          expect(adapter.request(:get)).to match_response(body: Fixture.xml)
        end

        it "tells em-http-request to skip verification when verify_mode is :none" do
          request.auth.ssl.verify_mode = :none
          connection_options = {tls: {verify_peer: false}}

          EventMachine::HttpRequest.expects(:new).with("https://example.com:443", connection_options)

          adapter
        end

        # verify_mode :none alone is accepted, so this pins that other ssl
        # settings next to it still raise instead of being silently ignored.
        it "still rejects other ssl settings when verify_mode is :none" do
          request.auth.ssl.verify_mode = :none
          request.auth.ssl.ca_cert_file = "spec/fixtures/client_cert.pem"

          expect { adapter.request(:get) }
            .to raise_error(HTTPI::NotSupportedError, "EM-HTTP-Request does not support SSL client auth")
        end

        it "rejects a client certificate it cannot read when verify_mode is :none" do
          request.auth.ssl.verify_mode = :none
          request.auth.ssl.cert_file = "spec/fixtures/does_not_exist.pem"
          request.auth.ssl.cert_key_file = "spec/fixtures/does_not_exist.key"
          em_http.expects(:get).never

          expect { adapter.request(:get) }
            .to raise_error(HTTPI::NotSupportedError, "EM-HTTP-Request does not support SSL client auth")
        end
      end

      context "(for HTTP requests)" do
        it "does not pass tls options to em-http-request" do
          EventMachine::HttpRequest.expects(:new).with("http://example.com:80", {})

          adapter
        end
      end
    end

    describe "deprecation" do
      before { HTTPI::Adapter::EmHttpRequest.instance_variable_set(:@deprecation_warned, nil) }

      it "warns once per process that the adapter is deprecated" do
        warning = /The em_http adapter is deprecated\. .*Use another adapter, such as :net_http\./

        expect {
          HTTPI::Adapter::EmHttpRequest.new(request)
          HTTPI::Adapter::EmHttpRequest.new(request)
        }.to output(warning).to_stderr

        expect { HTTPI::Adapter::EmHttpRequest.new(request) }.not_to output.to_stderr
      end
    end

    def http_message(body = Fixture.xml)
      message = EventMachine::HttpClient.new("http://example.com", {})
      message.instance_variable_set :@response, body
      message.instance_variable_set :@response_header, EventMachine::HttpResponseHeader.new
      message.response_header["Accept-encoding"] = "utf-8"
      message.response_header.http_status = "200"
      message
    end
  end
end
