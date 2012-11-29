require "spec_helper"
require "integration/server"

describe "SSL authentication" do

  before :all do
    WebMock.allow_net_connect!

    @host = "localhost"
    @port = 17172

    @url = "https://#{@host}:#{@port}/"
    @fake_url = "https://127.0.0.1:#{@port}/"

    @server = IntegrationServer.run(:host => @host, :port => @port, :ssl => true)
  end

  after :all do
    @server.stop
  end

  HTTPI::Adapter::ADAPTERS.keys.each do |adapter|
    context "with #{adapter}" do

      if adapter == :em_http && RUBY_VERSION =~ /1\.8/
        # em_http depends on fibers
      elsif adapter == :curb && RUBY_PLATFORM =~ /java/
        # curb does not run on jruby
      elsif adapter == :em_http && RUBY_VERSION >= "1.9.0" && RUBY_PLATFORM =~ /java/
        it "fails for whatever reason"
      else

        around :each do |example|
          if adapter == :em_http && RUBY_VERSION >= "1.9.0"
            # dependencies are loaded upon request, so we need to manually require this
            require "em-synchrony"

            EM.synchrony do
              example.run
              EM.stop
            end
          else
            example.run
          end
        end

        # 105 ssl
        if adapter == :httpclient || adapter == :curb
          it "raises when no certificate was set up" do
            expect { HTTPI.post(@url, "", adapter) }.to raise_error(HTTPI::SSLError)
          end
        else
          if adapter == :net_http && RUBY_VERSION >= "1.9"
            it "raises in 1.9, but does not raise in 1.8"
          else
            it "does not raise when no certificate was set up" do
              expect { HTTPI.post(@url, "", adapter) }.to_not raise_error(HTTPI::SSLError)
            end
          end
        end

        # 106 ssl ca
        it "works when set up properly" do
          unless adapter == :em_http
            request = HTTPI::Request.new(@url + "hello")
            request.auth.ssl.ca_cert_file = IntegrationServer.ssl_ca_file

            response = HTTPI.get(request, adapter)
            expect(response.body).to eq("get")
          end
        end

        # 107 ssl hostname
        if adapter == :em_http
          it "raises when configured for ssl client auth" do
            request = HTTPI::Request.new(@fake_url)
            request.auth.ssl.ca_cert_file = IntegrationServer.ssl_ca_file

            expect { HTTPI.get(request, adapter) }.
              to raise_error(HTTPI::NotSupportedError, "EM-HTTP-Request does not support SSL client auth")
          end
        else
          it "raises when the server could not be verified" do
            request = HTTPI::Request.new(@fake_url)
            request.auth.ssl.ca_cert_file = IntegrationServer.ssl_ca_file

            expect { HTTPI.get(request, adapter) }.to raise_error(HTTPI::SSLError)
          end
        end

      end
    end
  end
end
