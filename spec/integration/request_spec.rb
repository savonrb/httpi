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
    WebMock.allow_net_connect!
    
    @username = @password = "user1"
    @error_message = "Authorization Required"
    @example_web_page = "Example Web Page"
    @content_type = "text/html"
  end

  shared_examples_for "an HTTP client" do
    it "and execute an HTTP GET request" do
      response = HTTPI.get "http://example.com", adapter
      response.body.should include(@example_web_page)
      response.headers["Content-Type"].should include(@content_type)
    end

    it "and execute an HTTP POST request" do
      response = HTTPI.post "http://example.com", "<some>xml</some>", adapter
      response.body.should include(@example_web_page)
      response.headers["Content-Type"].should include(@content_type)
    end

    it "and execute an HTTP HEAD request" do
      response = HTTPI.head "http://example.com", adapter
      response.code.should == 200
      response.headers["Content-Type"].should include(@content_type)
    end

    it "and execute an HTTP PUT request" do
      response = HTTPI.put "http://example.com", "<some>xml</some>", adapter
      response.body.should include("PUT is not allowed")
      response.headers["Content-Type"].should include(@content_type)
    end

    it "and execute an HTTP DELETE request" do
      response = HTTPI.delete "http://example.com", adapter
      response.body.should include("DELETE is not allowed")
      response.headers["Content-Type"].should include(@content_type)
    end
  end

  shared_examples_for "it works with HTTP basic auth" do
    it "and access a secured page" do
      request = HTTPI::Request.new :url => "http://test.webdav.org/auth-basic/"
      request.auth.basic @username, @password

      response = HTTPI.get request, adapter
      response.body.should_not include(@error_message)
    end
  end

  shared_examples_for "it works with HTTP digest auth" do
    it "and access a secured page" do
      request = HTTPI::Request.new :url => "http://test.webdav.org/auth-digest/"
      request.auth.digest @username, @password

      response = HTTPI.get request, adapter
      response.body.should_not include(@error_message)
    end
  end

  HTTPI::Adapter.adapters.keys.each do |adapter|
    context "using :#{adapter}" do
      let(:adapter) { adapter }
      it_should_behave_like "an HTTP client"
      it_should_behave_like "it works with HTTP basic auth"
    end
  end

  (HTTPI::Adapter.adapters.keys - [:net_http]).each do |adapter|
    context "using :#{adapter}" do
      let(:adapter) { adapter }
      it_should_behave_like "it works with HTTP digest auth"
    end
  end

end
