require "spec_helper"
require "httpi"

describe HTTPI do
  let(:client) { HTTPI }

  # Uses the WebDAV Testing Server:
  # http://test.webdav.org/

  before :all do
    @username = @password = "user1"
    @error_message = "Authorization Required"
  end

  HTTPI::Adapter.adapters.keys.each do |adapter|
    context "using :#{adapter}" do
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
