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

    it "should set the adapter to use" do
      adapter.use.should_not == :curb

      adapter.use = :curb
      adapter.use.should == :curb
    end

    it "should default to use the HTTPClient adapter" do
      adapter.use.should == :httpclient
    end

    it "should load the adapter's client library" do
      adapter.expects(:require).with("httpclient")
      adapter.use = :httpclient
    end

    it "should raise an ArgumentError in case of an invalid adapter" do
      lambda { adapter.use = :unknown }.should raise_error(ArgumentError)
    end
  end

  describe ".load" do
    context "called with a valid adapter" do
      it "should return the adapter's name and class" do
        adapter.load(:curb).should == [:curb, HTTPI::Adapter::Curb]
      end
    end

    context "called with nil" do
      it "should return the default adapter's name and class" do
        adapter.load(nil).should == [:httpclient, HTTPI::Adapter::HTTPClient]
      end
    end

    context "called with an invalid adapter" do
      it "should raise an ArgumentError" do
        lambda { adapter.use = :unknown }.should raise_error(ArgumentError)
      end
    end
  end

end
