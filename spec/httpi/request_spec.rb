require "spec_helper"

describe HTTPI::Request do

  let(:request) do
    HTTPI::Request.new
  end

  describe ".new" do
    it "accepts a url" do
      request = HTTPI::Request.new some(:url)
      request.url.should == URI(some(:url))
    end

    it "accepts a url and headers" do
      request = HTTPI::Request.new some(:url), some(:headers)

      request.url.should == URI(some(:url))
      request.headers.should == some(:headers)
    end

    it "accepts a url, headers and a body" do
      request = HTTPI::Request.new some(:url), some(:headers), some(:body)

      request.url.should == URI(some(:url))
      request.headers.should == some(:headers)
      request.body.should == some(:body)
    end
  end

  describe "#url" do
    it "accepts a String" do
      request.url = some(:url)
      request.url.should == URI(some(:url))
    end

    it "accepts a URI" do
      request.url = URI(some(:url))
      request.url.should == URI(some(:url))
    end

    it "raises in case of an invalid url" do
      expect { request.url = "invalid" }.
        to raise_error(ArgumentError, "Invalid URL: invalid" )
    end
  end

  describe "#proxy" do
    it "accepts a String" do
      request.proxy = some(:url)
      request.proxy.should == URI(some(:url))
    end

    it "accepts a URI" do
      request.proxy = URI(some(:url))
      request.proxy.should == URI(some(:url))
    end

    it "raises in case of an invalid url" do
      expect { request.proxy = "proxy" }.
        to raise_error(ArgumentError, "Invalid URL: proxy" )
    end
  end

  describe "#ssl" do
    it "returns false if no request url was specified" do
      request.should_not be_ssl
    end

    it "returns false if the request url does not start with https" do
      request.url = some(:url)
      request.should_not be_ssl
    end

    it "returns true if the request url starts with https" do
      request.url = some(:ssl_url)
      request.should be_ssl
    end

    context "with an explicit value" do
      it "returns the value" do
        request.ssl = true
        request.should be_ssl
      end
    end
  end

  describe "#headers" do
    it "accepts a Hash of HTTP request headers" do
      request.headers = some(:headers)
      request.headers.should == some(:headers)
    end

    it "defaults to return an empty Hash" do
      request.headers.should == {}
    end
  end

  describe "#gzip" do
    it "adds the proper 'Accept-Encoding' header" do
      request.gzip
      request.headers["Accept-Encoding"].should == "gzip,deflate"
    end
  end

  describe "#body" do
    it "sets the request body" do
      request.body = some(:body)
      request.body.should == some(:body)
    end
  end

  describe "#open_timeout" do
    it "sets the open timeout" do
      request.open_timeout = 30
      request.open_timeout.should == 30
    end
  end

  describe "#read_timeout" do
    it "sets the read timeout" do
      request.read_timeout = 45
      request.read_timeout.should == 45
    end
  end

  describe "#auth" do
    it "returns the authentication" do
      request.auth.should be_an(HTTPI::Auth::Config)
    end

    it "memoizes the authentication" do
      request.auth.should equal(request.auth)
    end
  end

  describe "#auth?" do
    it "returns true when auth credentials are specified" do
      request.auth.basic "username", "password"
      request.auth?.should be_true
    end

    it "returns false otherwise" do
      request.auth?.should be_false
    end
  end

end
