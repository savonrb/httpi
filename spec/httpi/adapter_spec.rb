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

      expect(HTTPI::Adapter::ADAPTERS[:custom]).to include(:class => klass, :deps => deps)
      expect(HTTPI::Adapter::ADAPTER_CLASS_MAP[klass]).to be(name)
    end
  end

  describe ".use" do
    around do |example|
      adapter.use = nil
      example.run
      adapter.use = nil
    end

    it "sets the adapter to use" do
      expect(adapter.use).not_to eq(:net_http)

      adapter.use = :net_http
      expect(adapter.use).to eq(:net_http)
    end

    it "defaults to use the HTTPClient adapter" do
      expect(adapter.use).to eq(:httpclient)
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
        expect(adapter.load(:net_http)).to eq(HTTPI::Adapter::NetHTTP)
      end
    end

    context "called with nil" do
      it "returns the default adapter's name and class" do
        expect(adapter.load(nil)).to eq(HTTPI::Adapter::HTTPClient)
      end
    end

    context "called with an invalid adapter" do
      it "raises an ArgumentError" do
        expect { adapter.use = :unknown }.to raise_error(ArgumentError)
      end
    end
  end

end
