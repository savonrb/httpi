require "spec_helper"
require "httpi/request"

describe HTTPI::Request do
  let(:request) { HTTPI::Request.new }

  describe ".new" do
    it "accepts a Hash of accessors to set" do
      request = HTTPI::Request.new :url => "http://example.com", :open_timeout => 30
      request.url.should == URI("http://example.com")
      request.open_timeout.should == 30
    end

    it "accepts a Hash of authentication credentials to set" do
      request = HTTPI::Request.new :basic_auth => ["username", "password"]
      request.basic_auth.should == ["username", "password"]
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

  describe "#headers" do
    it "lets you specify a Hash of HTTP request headers" do
      request.headers = { "Accept-Encoding" => "gzip" }
      request.headers.should == { "Accept-Encoding" => "gzip" }
    end

    it "defaults to return an empty Hash" do
      request.headers.should == {}
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

  describe "#basic_auth" do
    it "lets you specify the basic auth credentials" do
      request.basic_auth "username", "password"
      request.basic_auth.should == ["username", "password"]
    end
   
    it "also accepts an Array of credentials" do
      request.basic_auth ["username", "password"]
      request.basic_auth.should == ["username", "password"]
    end

    it "lets you reset the credentials" do
      request.basic_auth "username", "password"
      request.basic_auth.should == ["username", "password"]

      request.basic_auth nil
      request.basic_auth.should be_nil
    end
  end

  describe "#digest_auth" do
    it "lets you specify the digest auth credentials" do
      request.digest_auth "username", "password"
      request.digest_auth.should == ["username", "password"]
    end
   
    it "also accepts an Array of credentials" do
      request.digest_auth ["username", "password"]
      request.digest_auth.should == ["username", "password"]
    end

    it "lets you reset the credentials" do
      request.digest_auth "username", "password"
      request.digest_auth.should == ["username", "password"]

      request.digest_auth nil
      request.digest_auth.should be_nil
    end
  end

end
