require "spec_helper"
require "httpi/adapter"

describe HTTPI::Adapter do
  let(:adapter) { HTTPI::Adapter }

  describe ".use" do
    around do |example|
      adapter.use = nil
      example.run
      adapter.use = nil
    end

    it "sets the adapter to use" do
      adapter.use.should_not == :net_http

      adapter.use = :net_http
      adapter.use.should == :net_http
    end

    it "loads the adapter's client library" do
      adapter.expects(:require).with("net/http")
      adapter.expects(:require).with("net/ntlm_http")
      adapter.use = :net_http
    end

    it "raises an ArgumentError in case of an invalid adapter" do
      expect { adapter.use = :unknown }.to raise_error(ArgumentError)
    end
  end

  describe ".load" do
    context "called with a valid adapter" do
      it "returns the adapter's name and class" do
        adapter.load(:net_http).should == [:net_http, HTTPI::Adapter::NetHTTP]
      end
    end

    context "called with nil" do
      it "returns an empty array" do
        adapter.load(nil).should == []
      end
    end

    context "called with an invalid adapter" do
      it "raises an ArgumentError" do
        expect { adapter.use = :unknown }.to raise_error(ArgumentError)
      end
    end
  end

end
