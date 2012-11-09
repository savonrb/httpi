require "spec_helper"
require "httpi"
require "integration/ssl_server"

describe "SSL authentication" do

  before :all do
    WebMock.allow_net_connect!

    @host = "localhost"
    @port = 17171
    @ssl_port = 17172
    @proxy_port = 17173

    @url = "http://#{@host}:#{@port}/"
    @ssl_url = "https://localhost:#{@ssl_port}/"
    @ssl_fake_url = "https://127.0.0.1:#{@ssl_port}/"
    @proxy_url = "http://#{@host}:#{@proxy_port}/"

    @ssl_server = SSLServer.new(@host, @ssl_port)
  end

  def teardown
    @ssl_server.shutdown if @ssl_server
  end

  HTTPI::Adapter::ADAPTERS.keys.each do |adapter|
    context "with #{adapter}" do

      if adapter == :em_http && RUBY_VERSION >= "1.9.0"
        # dependencies are loaded upon request, so we need to manually require this
        require "em-synchrony"

        around(:each) do |example|
          EM.synchrony do
            example.run
            EM.stop
          end
        end
      end

      # 105 ssl
      it "raises when no certificate was set up" do
        if adapter != :em_http
          expect { HTTPI.post(@ssl_url + "hello", "", adapter) }.
            to raise_error(HTTPI::SSLError)
        else
          pending "Investigate why em_http does not raise an error"
        end
      end

      # 106 ssl ca
      it "works when set up properly" do
        unless adapter == :em_http
          ca_file = File.expand_path("../fixtures/ca_all.pem", __FILE__)
          request = HTTPI::Request.new(@ssl_url + "hello")
          request.auth.ssl.ca_cert_file = ca_file

          response = HTTPI.get(request, adapter)
          expect(response.body).to eq("hello ssl")
        end
      end

      # 107 ssl hostname
      if adapter == :em_http
        it "raises when configured for ssl client auth" do
          ca_file = File.expand_path("../fixtures/ca_all.pem", __FILE__)
          request = HTTPI::Request.new(@ssl_fake_url + "hello")
          request.auth.ssl.ca_cert_file = ca_file

          expect { HTTPI.get(request, adapter) }.
            to raise_error(HTTPI::NotSupportedError, "EM-HTTP-Request does not support SSL client auth")
        end
      else
        it "raises when the server could not be verified" do
          ca_file = File.expand_path("../fixtures/ca_all.pem", __FILE__)
          request = HTTPI::Request.new(@ssl_fake_url + "hello")
          request.auth.ssl.ca_cert_file = ca_file

          expect { HTTPI.get(request, adapter) }.to raise_error(HTTPI::SSLError)
        end
      end

    end
  end
end
