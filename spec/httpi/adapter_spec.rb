require "spec_helper"
require "httpi/adapter"

describe HTTPI::Adapter do
  let(:adapter) { HTTPI::Adapter }

  describe ".register" do
    it "registers a new adapter" do
      name  = :custom
      klass = Class.new
      deps  = %w(some_dependency)

      adapter.register(name, klass, deps)

      HTTPI::Adapter::ADAPTERS[:custom].should include(:class => klass, :deps => deps)
      HTTPI::Adapter::ADAPTER_CLASS_MAP[klass].should be(name)
    end
  end

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

    it "defaults to use the HTTPClient adapter" do
      adapter.use.should == :httpclient
    end

    it "loads the adapter's client library" do
      adapter.expects(:require).with("httpclient")
      adapter.use = :httpclient
    end

    it "raises an ArgumentError in case of an invalid adapter" do
      expect { adapter.use = :unknown }.to raise_error(ArgumentError)
    end
  end

  describe ".load" do
    context "called with a valid adapter" do
      it "returns the adapter's name and class" do
        adapter.load(:net_http).should == HTTPI::Adapter::NetHTTP
      end
    end

    context "called with nil" do
      it "returns the default adapter's name and class" do
        adapter.load(nil).should == HTTPI::Adapter::HTTPClient
      end
    end

    context "called with an invalid adapter" do
      it "raises an ArgumentError" do
        expect { adapter.use = :unknown }.to raise_error(ArgumentError)
      end
    end
  end

end
