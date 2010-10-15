require "spec_helper"
require "httpi/request"

describe HTTPI::Request do
  let(:request) { HTTPI::Request.new }

  describe ".new" do
    it "should accept just a url" do
      request = HTTPI::Request.new "http://example.com"
      request.url.should == URI("http://example.com")
    end

    it "should accept a Hash of accessors to set" do
      request = HTTPI::Request.new :url => "http://example.com", :open_timeout => 30
      request.url.should == URI("http://example.com")
      request.open_timeout.should == 30
    end
  end

  describe "#url" do
    it "lets you specify the URL to access as a String" do
      request.url = "http://example.com"
      request.url.should == URI("http://example.com")
    end

    it "also accepts a URI object" do
      request.url = URI("http://example.com")
      request.url.should == URI("http://example.com")
    end

    it "raises an ArgumentError in case the url does not seem to be valid" do
      lambda { request.url = "invalid" }.should raise_error(ArgumentError)
    end
  end

  describe "#proxy" do
    it "lets you specify the proxy URL to use as a String" do
      request.proxy = "http://proxy.example.com"
      request.proxy.should == URI("http://proxy.example.com")
    end

    it "also accepts a URI object" do
      request.proxy = URI("http://proxy.example.com")
      request.proxy.should == URI("http://proxy.example.com")
    end

    it "raises an ArgumentError in case the url does not seem to be valid" do
      lambda { request.proxy = "invalid" }.should raise_error(ArgumentError)
    end
  end

  describe "#ssl" do
    it "should return false if no request url was specified" do
      request.should_not be_ssl
    end

    it "should return false if the request url does not start with https" do
      request.url = "http://example.com"
      request.should_not be_ssl
    end

    it "should return true if the request url starts with https" do
      request.url = "https://example.com"
      request.should be_ssl
    end

    context "with an explicit value" do
      it "should return the value" do
        request.ssl = true
        request.should be_ssl
      end
    end
  end

  describe "#headers" do
    it "lets you specify a Hash of HTTP request headers" do
      request.headers = { "Accept-Encoding" => "gzip" }
      request.headers.should == { "Accept-Encoding" => "gzip" }
    end

    it "defaults to return an empty Hash" do
      request.headers.should == {}
    end
  end

  describe "#gzip" do
    it "should add the proper 'Accept-Encoding' header" do
      request.gzip
      request.headers["Accept-Encoding"].should == "gzip,deflate"
    end
  end

  describe "#body" do
    it "lets you specify the HTTP request body" do
      request.body = "<some>xml</some>"
      request.body.should == "<some>xml</some>"
    end
  end

  describe "#open_timeout" do
    it "lets you specify the open timeout" do
      request.open_timeout = 30
      request.open_timeout.should == 30
    end
  end

  describe "#read_timeout" do
    it "lets you specify the read timeout" do
      request.read_timeout = 45
      request.read_timeout.should == 45
    end
  end

  describe "#auth" do
    it "should return the authentication object" do
      request.auth.should be_an(HTTPI::Auth::Config)
    end

    it "should memoize the authentication object" do
      request.auth.should equal(request.auth)
    end
  end

  describe "#auth?" do
    it "should return true when auth credentials are specified" do
      request.auth.basic "username", "password"
      request.auth?.should be_true
    end

    it "should return false otherwise" do
      request.auth?.should be_false
    end
  end

end
