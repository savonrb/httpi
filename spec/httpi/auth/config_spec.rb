require "spec_helper"
require "httpi/auth/config"

describe HTTPI::Auth::Config do
  let(:auth) { HTTPI::Auth::Config.new }

  describe "#basic" do
    it "lets you specify the basic auth credentials" do
      auth.basic "username", "password"
      auth.basic.should == ["username", "password"]
    end

    it "also accepts an Array of credentials" do
      auth.basic ["username", "password"]
      auth.basic.should == ["username", "password"]
    end

    it "sets the authentication type to :basic" do
      auth.basic "username", "password"
      auth.type.should == :basic
    end
  end

  describe "#basic?" do
    it "defaults to return false" do
      auth.should_not be_basic
    end

    it "returns true for HTTP basic auth" do
      auth.basic "username", "password"
      auth.should be_basic
    end
  end

  describe "#digest" do
    it "lets you specify the digest auth credentials" do
      auth.digest "username", "password"
      auth.digest.should == ["username", "password"]
    end

    it "also accepts an Array of credentials" do
      auth.digest ["username", "password"]
      auth.digest.should == ["username", "password"]
    end

    it "sets the authentication type to :digest" do
      auth.digest "username", "password"
      auth.type.should == :digest
    end
  end

  describe "#digest?" do
    it "defaults to return false" do
      auth.should_not be_digest
    end

    it "returns true for HTTP digest auth" do
      auth.digest "username", "password"
      auth.should be_digest
    end
  end

  describe "#gssnegotiate" do
    it "sets the authentication type to :gssnegotiate" do
      auth.gssnegotiate
      auth.type.should == :gssnegotiate
    end
  end

  describe "#gssnegotiate?" do
    it "defaults to return false" do
      auth.should_not be_gssnegotiate
    end

    it "returns true for HTTP Negotiate auth" do
      auth.gssnegotiate
      auth.should be_gssnegotiate
    end
  end

  describe "#http?" do
    it "defaults to return false" do
      auth.should_not be_http
    end

    it "returns true for HTTP basic auth" do
      auth.basic "username", "password"
      auth.should be_http
    end

    it "returns true for HTTP digest auth" do
      auth.digest "username", "password"
      auth.should be_http
    end
  end

  describe "#ssl" do
    it "returns the HTTPI::Auth::SSL object" do
      auth.ssl.should be_a(HTTPI::Auth::SSL)
    end
  end

  describe "#ssl?" do
    it "defaults to return false" do
      auth.should_not be_ssl
    end

    it "returns true for SSL client auth" do
      auth.ssl.cert_key_file = "spec/fixtures/client_key.pem"
      auth.ssl.cert_file = "spec/fixtures/client_cert.pem"

      auth.should be_ssl
    end
  end

  describe "#type" do
    it "returns the authentication type" do
      auth.basic "username", "password"
      auth.type.should == :basic
    end
  end

  describe "#credentials" do
    it "returns the credentials for HTTP basic auth" do
      auth.basic "username", "basic"
      auth.credentials.should == ["username", "basic"]
    end

    it "returns the credentials for HTTP digest auth" do
      auth.digest "username", "digest"
      auth.credentials.should == ["username", "digest"]
    end
  end

  describe "#ntlm" do
    it "lets you specify the ntlm auth credentials" do
      auth.ntlm "username", "password"
      auth.ntlm.should == ["username", "password"]
    end

    it "also accepts an Array of credentials" do
      auth.ntlm ["username", "password"]
      auth.ntlm.should == ["username", "password"]
    end

    it "sets the authentication type to :ntlm" do
      auth.ntlm "username", "password"
      auth.type.should == :ntlm
    end
  end

  describe "#ntlm?" do
    it "defaults to return false" do
      auth.should_not be_ntlm
    end

    it "returns true for HTTP ntlm auth" do
      auth.ntlm "username", "password"
      auth.should be_ntlm
    end
  end

end
