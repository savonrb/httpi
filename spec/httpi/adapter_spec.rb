require "spec_helper"
require "httpi/adapter"

describe HTTPI::Adapter do
  let(:adapter) { HTTPI::Adapter }

  describe ".use" do
    it "should default to HTTPClient" do
      adapter.use.should == :httpclient
    end
    
    it "should accept an adapter to use" do
      adapter.use = :curb
      adapter.use.should == :curb
      
      # reset to default
      adapter.use = HTTPI::Adapter::DEFAULT
    end

    it "should raise an ArgumentError in case of an invalid adapter" do
      lambda { adapter.use = :unknown }.should raise_error(ArgumentError)
    end
  end

  describe ".adapters" do
    it "should return a memoized Hash of adapters" do
      adapter.adapters.should have(2).items
      adapter.adapters.should include(
        :httpclient => HTTPI::Adapter::HTTPClient,
        :curb => HTTPI::Adapter::Curb
      )
    end
  end

  describe ".find" do
    it "should return the adapter for a given Symbol" do
      adapter.find(:httpclient).should == HTTPI::Adapter::HTTPClient
    end

    it "should raise an ArgumentError in case of an invalid adapter" do
      lambda { adapter.find :unknown }.should raise_error(ArgumentError)
    end
  end

end
