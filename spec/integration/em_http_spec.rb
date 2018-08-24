require "spec_helper"
require "integration/support/server"

describe HTTPI::Adapter::EmHttpRequest do

  # em_http is not supported on ruby 1.8
  unless RUBY_VERSION =~ /1\.8/
    require "em-synchrony"

    subject(:adapter) { :em_http }

    around :each do |example|
      EM.synchrony do
        example.run
        EM.stop
      end
    end

    context "http requests" do
      before :all do
        # for some reason, these specs don't work with "localhost". [dh, 2012-12-15]
        @server = IntegrationServer.run(:host => "127.0.0.1")
      end

      after :all do
        @server.stop
      end

      it "sends and receives HTTP headers" do
        request = HTTPI::Request.new(@server.url + "x-header")
        request.headers["X-Header"] = "HTTPI"

        response = HTTPI.get(request, adapter)
        expect(response.body).to include("HTTPI")
      end

      it "it supports headers with multiple values" do
        request = HTTPI::Request.new(@server.url + "cookies")

        response = HTTPI.get(request, adapter)
        cookies = ["cookie1=chip1; path=/", "cookie2=chip2; path=/"]
        expect(response.headers["Set-Cookie"]).to eq(cookies)
      end

      if RUBY_PLATFORM =~ /java/
        pending <<-MSG
          It seems like JRuby is missing support for inactivity timeout! See related issues on GitHub:
            - https://github.com/eventmachine/eventmachine/issues/155
            - https://github.com/eventmachine/eventmachine/pull/312
        MSG
      else
        it "it supports read timeout" do
          request = HTTPI::Request.new(@server.url + "timeout")
          request.read_timeout = 0.5 # seconds

          expect { HTTPI.get(request, adapter) }
            .to raise_error { |error|
              expect(error).to be_a(HTTPI::Adapter::EmHttpRequest::EmHttpTimeoutError)
              expect(error).to be_a(HTTPI::TimeoutError)
            }
        end
      end

      it "executes GET requests" do
        response = HTTPI.get(@server.url, adapter)
        expect(response.body).to eq("get")
        expect(response.headers["Content-Type"]).to eq("text/plain")
      end

      it "executes POST requests" do
        response = HTTPI.post(@server.url, "<some>xml</some>", adapter)
        expect(response.body).to eq("post")
        expect(response.headers["Content-Type"]).to eq("text/plain")
      end

      it "executes HEAD requests" do
        response = HTTPI.head(@server.url, adapter)
        expect(response.code).to eq(200)
        expect(response.headers["Content-Type"]).to eq("text/plain")
      end

      it "executes PUT requests" do
        response = HTTPI.put(@server.url, "<some>xml</some>", adapter)
        expect(response.body).to eq("put")
        expect(response.headers["Content-Type"]).to eq("text/plain")
      end

      it "executes DELETE requests" do
        response = HTTPI.delete(@server.url, adapter)
        expect(response.body).to eq("delete")
        expect(response.headers["Content-Type"]).to eq("text/plain")
      end

      it "supports basic authentication" do
        request = HTTPI::Request.new(@server.url + "basic-auth")
        request.auth.basic("admin", "secret")

        response = HTTPI.get(request, adapter)
        expect(response.body).to eq("basic-auth")
      end

      # it does not support digest authentication

      # it does not support chunked response
    end

    # it does not support ssl authentication

  end
end
