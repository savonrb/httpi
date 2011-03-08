require "spec_helper"
require "httpi/adapter"


describe HTTPI::Adapter do
  let(:adapter) { HTTPI::Adapter }

  describe ".use" do
    it "should set the adapter to use" do
      adapter.use.should_not == :curb

      adapter.use = :curb
      adapter.use.should == :curb

      adapter.use = nil  # reset
    end

    it "should default to use the HTTPClient adapter" do
      adapter.use.should == :httpclient
    end

    it "should raise an ArgumentError in case of an invalid adapter" do
      lambda { adapter.use = :unknown }.should raise_error(ArgumentError)
    end
  end

  describe ".load" do
    it "should return the adapter name and it's class for a given adapter" do
      adapter.load(:curb).should == [:curb, HTTPI::Adapter::Curb]
    end

    it "should return the HTTPClient adapter name and it's class by default" do
      adapter.load.should == [:httpclient, HTTPI::Adapter::HTTPClient]
    end

    it "should raise an ArgumentError in case of an invalid adapter" do
      lambda { adapter.use = :unknown }.should raise_error(ArgumentError)
    end
  end

end
