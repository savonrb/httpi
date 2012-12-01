require "spec_helper"
require "integration/server"

describe "SSL authentication" do

  before :all do
    WebMock.allow_net_connect!
    @server = IntegrationServer.run(:ssl => true)
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

        if adapter == :httpclient || adapter == :curb
          it "raises when no certificate was set up" do
            expect { HTTPI.post(@server.url, "", adapter) }.to raise_error(HTTPI::SSLError)
          end
        else
          if adapter == :net_http && RUBY_VERSION >= "1.9"
            it "raises in 1.9, but does not raise in 1.8"
          else
            it "does not raise when no certificate was set up" do
              expect { HTTPI.post(@server.url, "", adapter) }.to_not raise_error(HTTPI::SSLError)
            end
          end
        end

        it "works when set up properly" do
          unless adapter == :em_http
            request = HTTPI::Request.new(@server.url)
            request.auth.ssl.ca_cert_file = IntegrationServer.ssl_ca_file

            response = HTTPI.get(request, adapter)
            expect(response.body).to eq("get")
          end
        end

      end
    end
  end
end
