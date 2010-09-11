require "spec_helper"
require "httpi/adapter"

describe HTTPI::Adapter do

  describe ".use" do
    it "should default to HTTPClient" do
      HTTPI::Adapter.use.should == :httpclient
    end
  end

  describe ".use=" do
    it "should accept an adapter to use" do
      HTTPI::Adapter.use = :curb
      HTTPI::Adapter.use.should == :curb
      
      # reset to default
      HTTPI::Adapter.use = HTTPI::Adapter::DEFAULT
    end

    it "should raise an ArgumentError in case of an invalid adapter" do
      lambda { HTTPI::Adapter.use = :unknown }.should raise_error(ArgumentError)
    end
  end

  describe ".adapters" do
    it "should return a memoized Hash of adapters" do
      HTTPI::Adapter.adapters.should have(2).items
      HTTPI::Adapter.adapters.should include(
        :httpclient => HTTPI::Adapter::HTTPClient,
        :curb => HTTPI::Adapter::Curb
      )
    end
  end

  describe ".find" do
    it "should return the adapter for a given Symbol" do
      HTTPI::Adapter.find(:httpclient).should == HTTPI::Adapter::HTTPClient
    end

    it "should raise an ArgumentError in case of an invalid adapter" do
      lambda { HTTPI::Adapter.find :unknown }.should raise_error(ArgumentError)
    end
  end

end
