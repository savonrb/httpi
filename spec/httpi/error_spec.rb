require "spec_helper"
require "support/error_helper"

describe HTTPI do
  include ErrorHelper

  context "with :httpclient" do
    it "tags Errno::ECONNREFUSED with HTTPI::ConnectionError" do
      expect_error(Errno::ECONNREFUSED, "Connection refused - connect(2)").to be_tagged_with(HTTPI::ConnectionError)
    end

    def fake_error(error, message)
      request(:httpclient) { |client| client.expects(:request).raises(error, message) }
    end
  end

  unless RUBY_PLATFORM =~ /java/
    context "with :curb" do
      it "tags Curl::Err::ConnectionFailedError with HTTPI::ConnectionError" do
        expect_error(Curl::Err::ConnectionFailedError, "Curl::Err::ConnectionFailedError").to be_tagged_with(HTTPI::ConnectionError)
      end

      def fake_error(error, message)
        request(:curb) { |client| client.expects(:send).raises(error, message) }
      end
    end
  end

  context "with :net_http" do
    it "tags Errno::ECONNREFUSED with HTTPI::ConnectionError" do
      expect_error(Errno::ECONNREFUSED, "Connection refused - connect(2)").to be_tagged_with(HTTPI::ConnectionError)
    end

    def fake_error(error, message)
      request(:net_http) { |client| client.expects(:start).raises(error, message) }
    end
  end

  def request(adapter)
    HTTPI.get("http://example.com", adapter) { |client| yield client }
  end

end
