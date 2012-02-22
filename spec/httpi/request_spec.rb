require "spec_helper"
require "httpi/request"

describe HTTPI::Request do
  let(:request) { HTTPI::Request.new }

  describe ".new" do
    it "accepts a url" do
      request = HTTPI::Request.new "http://example.com"
      request.url.should == URI("http://example.com")
    end

    it "accepts a Hash of accessors to set" do
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

    it "raises an ArgumentError in case of an invalid url" do
      expect { request.url = "invalid" }.to raise_error(ArgumentError)
    end

    it "uses username and password as basic authentication if present in the URL" do
      request.url = "http://username:password@example.com"
      request.auth.basic.should == ['username', 'password']
    end

    it "uses a blank password if only username is specified in the URL" do
      request.url = "http://username@example.com"
      request.auth.basic.should == ['username', '']
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

    it "raises an ArgumentError in case of an invalid url" do
      expect { request.proxy = "invalid" }.to raise_error(ArgumentError)
    end
  end

  describe "#ssl" do
    it "returns false if no request url was specified" do
      request.should_not be_ssl
    end

    it "returns false if the request url does not start with https" do
      request.url = "http://example.com"
      request.should_not be_ssl
    end

    it "returns true if the request url starts with https" do
      request.url = "https://example.com"
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
    it "lets you specify a Hash of HTTP request headers" do
      request.headers = { "Accept-Encoding" => "gzip" }
      request.headers.should == { "Accept-Encoding" => "gzip" }
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
    it "lets you specify the HTTP request body using a String" do
      request.body = "<some>xml</some>"
      request.body.should == "<some>xml</some>"
    end

    it "lets you specify the HTTP request body using a Hash" do
      request.body = {:foo => :bar, :baz => :foo}
      request.body.split("&").should =~ ["foo=bar", "baz=foo"]
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
    it "returns the authentication object" do
      request.auth.should be_an(HTTPI::Auth::Config)
    end

    it "memoizes the authentication object" do
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
