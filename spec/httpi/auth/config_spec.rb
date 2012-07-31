require "spec_helper"
require "httpi/auth/config"

describe HTTPI::Auth::Config do
  let(:auth) { HTTPI::Auth::Config.new }

  describe "configuration" do
    class Crazy < HTTPI::Auth::Base
      def initialize(foo); @foo = foo; end
      attr_accessor :foo
      register :crazy
    end

    it 'registers new auth classes' do
      auth.should_not be_crazy
    end

    it 'configures auth' do
      auth.crazy('bar')
      auth.should be_crazy
      auth.crazy.foo.should eql 'bar'
    end
  end

  describe "#basic" do
    it "lets you specify the basic auth credentials" do
      auth.basic "username", "password"
      [auth.basic.username, auth.basic.password].should == ["username", "password"]
    end

    it "also accepts an Array of credentials" do
      auth.basic ["username", "password"]
      [auth.basic.username, auth.basic.password].should == ["username", "password"]
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
      [auth.digest.username, auth.digest.password].should == ["username", "password"]
    end

    it "also accepts an Array of credentials" do
      auth.digest ["username", "password"]
      [auth.digest.username, auth.digest.password].should == ["username", "password"]
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

end
