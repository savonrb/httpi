require "spec_helper"
require "httpi/auth/ssl"

describe HTTPI::Auth::SSL do

  describe "VERIFY_MODES" do
    it "contains the supported SSL verify modes" do
      HTTPI::Auth::SSL::VERIFY_MODES.should == [:none, :peer, :fail_if_no_peer_cert, :client_once]
    end
  end

  describe "#present?" do
    it "defaults to return false" do
      ssl = HTTPI::Auth::SSL.new
      ssl.should_not be_present
    end

    it "returns false if only a client key was specified" do
      ssl = HTTPI::Auth::SSL.new
      ssl.cert_key_file = "spec/fixtures/client_key.pem"

      ssl.should_not be_present
    end

    it "returns false if only a client key was specified" do
      ssl = HTTPI::Auth::SSL.new
      ssl.cert_file = "spec/fixtures/client_cert.pem"

      ssl.should_not be_present
    end

    it "returns true if both client key and cert are present" do
      ssl.should be_present
    end

    it "returns true of the verify_mode is :none" do
      ssl = HTTPI::Auth::SSL.new
      ssl.verify_mode = :none
      ssl.should be_present
    end
  end

  describe "#verify_mode" do
    it "defaults to return :peer" do
      ssl.verify_mode.should == :peer
    end

    it "sets the verify mode to use" do
      ssl = HTTPI::Auth::SSL.new

      ssl.verify_mode = :none
      ssl.verify_mode.should == :none
    end

    it "raises an ArgumentError if the given mode is not supported" do
      expect { ssl.verify_mode = :invalid }.to raise_error(ArgumentError)
    end
  end

  describe "#cert" do
    it "returns an OpenSSL::X509::Certificate for the given cert_file" do
      ssl.cert.should be_a(OpenSSL::X509::Certificate)
    end

    it "returns nil if no cert_file was given" do
      ssl = HTTPI::Auth::SSL.new
      ssl.cert.should be_nil
    end

    it "returns the explicitly given certificate if set" do
      ssl = HTTPI::Auth::SSL.new
      cert = OpenSSL::X509::Certificate.new
      ssl.cert = cert
      ssl.cert.should == cert
    end
  end

  describe "#cert_key" do
    it "returns a OpenSSL::PKey::RSA for the given cert_key" do
      ssl.cert_key.should be_a(OpenSSL::PKey::RSA)
    end

    it "returns nil if no cert_key_file was given" do
      ssl = HTTPI::Auth::SSL.new
      ssl.cert_key.should be_nil
    end

    it "returns the explicitly given key if set" do
      ssl = HTTPI::Auth::SSL.new
      key = OpenSSL::PKey::RSA.new
      ssl.cert_key = key
      ssl.cert_key.should == key
    end
  end

  describe "#ca_cert" do
    it "returns an OpenSSL::X509::Certificate for the given ca_cert_file" do
      ssl = HTTPI::Auth::SSL.new

      ssl.ca_cert_file = "spec/fixtures/client_cert.pem"
      ssl.ca_cert.should be_a(OpenSSL::X509::Certificate)
    end
  end

  describe "#openssl_verify_mode" do
    it "returns the OpenSSL verify mode for :none" do
      ssl = HTTPI::Auth::SSL.new

      ssl.verify_mode = :none
      ssl.openssl_verify_mode.should == OpenSSL::SSL::VERIFY_NONE
    end

    it "returns the OpenSSL verify mode for :peer" do
      ssl = HTTPI::Auth::SSL.new

      ssl.verify_mode = :peer
      ssl.openssl_verify_mode.should == OpenSSL::SSL::VERIFY_PEER
    end

    it "returns the OpenSSL verify mode for :fail_if_no_peer_cert" do
      ssl = HTTPI::Auth::SSL.new

      ssl.verify_mode = :fail_if_no_peer_cert
      ssl.openssl_verify_mode.should == OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT
    end

    it "returns the OpenSSL verify mode for :client_once" do
      ssl = HTTPI::Auth::SSL.new

      ssl.verify_mode = :client_once
      ssl.openssl_verify_mode.should == OpenSSL::SSL::VERIFY_CLIENT_ONCE
    end
  end

  def ssl
    ssl = HTTPI::Auth::SSL.new
    ssl.cert_key_file = "spec/fixtures/client_key.pem"
    ssl.cert_file = "spec/fixtures/client_cert.pem"
    ssl
  end

end
