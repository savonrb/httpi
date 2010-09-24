require "spec_helper"
require "httpi"

describe HTTPI do
  let(:client) { HTTPI }

  # Uses example.com for basic request methods and webdav.org
  # for HTTP basic and digest authentication.
  #
  # http://example.com
  # http://test.webdav.org

  before :all do
    @username = @password = "user1"
    @error_message = "Authorization Required"
    @example_web_page = "Example Web Page"
    @put_not_allowed = "The requested method PUT is not allowed"
  end

  HTTPI::Adapter.adapters.keys.each do |adapter|
    context "using :#{adapter}" do
      it "should execute an HTTP GET request" do
        response = HTTPI.get "http://example.com"
        response.body.should include(@example_web_page)
      end

      it "should execute an HTTP POST request" do
        response = HTTPI.post "http://example.com"
        response.body.should include(@example_web_page)
      end

      it "should execute an HTTP PUT request" do
        response = HTTPI.put "http://example.com"
        response.body.should include(@put_not_allowed)
      end

      context "with HTTP basic authentication" do
        it "requires a username and password" do
          request = HTTPI::Request.new :url => "http://test.webdav.org/auth-basic/"
          request.basic_auth @username, @password
          
          response = HTTPI.get request, adapter
          response.body.should_not include(@error_message)
        end
      end

      context "with HTTP digest authentication" do
        it "requires a username and password" do
          request = HTTPI::Request.new :url => "http://test.webdav.org/auth-digest/"
          request.digest_auth @username, @password
          
          response = HTTPI.get request, adapter
          response.body.should_not include(@error_message)
        end
      end
    end
  end

end
