require "spec_helper"

describe HTTPI::Auth::Config do

  let(:auth) do
    HTTPI::Auth::Config.new
  end

  describe "#basic" do
    it "accepts a username and password" do
      auth.basic "username", "password"
      auth.basic.should == ["username", "password"]
    end

    it "also accepts an Array" do
      auth.basic ["username", "password"]
      auth.basic.should == ["username", "password"]
    end

    it "sets the authentication type to :basic" do
      auth.basic "username", "password"
      auth.type.should == :basic
    end
  end

  describe "#basic?" do
    it "defaults to false" do
      auth.should_not be_basic
    end

    it "returns true for basic auth" do
      auth.basic "username", "password"
      auth.should be_basic
    end
  end

  describe "#digest" do
    it "accepts a username and password" do
      auth.digest "username", "password"
      auth.digest.should == ["username", "password"]
    end

    it "also accepts an Array" do
      auth.digest ["username", "password"]
      auth.digest.should == ["username", "password"]
    end

    it "sets the authentication type to :digest" do
      auth.digest "username", "password"
      auth.type.should == :digest
    end
  end

  describe "#digest?" do
    it "defaults to false" do
      auth.should_not be_digest
    end

    it "returns true for digest auth" do
      auth.digest "username", "password"
      auth.should be_digest
    end
  end

  describe "#http?" do
    it "defaults to false" do
      auth.should_not be_http
    end

    it "returns true for basic auth" do
      auth.basic "username", "password"
      auth.should be_http
    end

    it "returns true for digest auth" do
      auth.digest "username", "password"
      auth.should be_http
    end
  end

  describe "#ssl" do
    it "returns the ssl configuration" do
      auth.ssl.should be_a(HTTPI::Auth::SSL)
    end
  end

  describe "#ssl?" do
    it "defaults to false" do
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
    it "returns the credentials for basic auth" do
      auth.basic "username", "basic"
      auth.credentials.should == ["username", "basic"]
    end

    it "returns the credentials for digest auth" do
      auth.digest "username", "digest"
      auth.credentials.should == ["username", "digest"]
    end
  end

end
