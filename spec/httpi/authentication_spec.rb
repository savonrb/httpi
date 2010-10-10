require "spec_helper"
require "httpi/authentication"

describe HTTPI::Authentication do
  let(:auth) { HTTPI::Authentication.new }

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
    it "should default to return false" do
      auth.should_not be_digest
    end

    it "should return true for HTTP digest auth" do
      auth.digest "username", "password"
      auth.should be_digest
    end
  end

  describe "#type" do
    it "should return the authentication type" do
      auth.basic "username", "password"
      auth.type.should == :basic
    end
  end

  describe "#credentials" do
    it "return the credentials for HTTP basic auth" do
      auth.basic "username", "basic"
      auth.credentials.should == ["username", "basic"]
    end

    it "return the credentials for HTTP digest auth" do
      auth.digest "username", "digest"
      auth.credentials.should == ["username", "digest"]
    end
  end

end
