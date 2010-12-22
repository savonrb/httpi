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
    it "should return a Hash of adapter details" do
      adapter.adapters.should == {
        :httpclient => { :class => HTTPI::Adapter::HTTPClient, :require => "httpclient" },
        :curb       => { :class => HTTPI::Adapter::Curb,       :require => "curb" },
        :net_http   => { :class => HTTPI::Adapter::NetHTTP,    :require => "net/https" }
      }
    end

    it "should return a memoized Hash" do
      adapter.adapters.should equal(adapter.adapters)
    end
  end

  describe ".find" do
    it "should return the adapter name and class for a given Symbol" do
      adapter.find(:httpclient).should == [:httpclient, HTTPI::Adapter::HTTPClient]
    end

    it "should raise an ArgumentError in case of an invalid adapter" do
      lambda { adapter.find :unknown }.should raise_error(ArgumentError)
    end

    context "when the given adapter could not be found" do
      before do
        adapter.expects(:require).with("httpclient").raises(LoadError)
        adapter.expects(:require).with(HTTPI::Adapter.adapters[HTTPI::Adapter::FALLBACK][:require])
      end

      it "should fall back to use the HTTPI::Adapter::FALLBACK adapter" do
        adapter.find :httpclient
      end

      it "should log that the adapter to use could not be required" do
        HTTPI.expects(:log).with(
          "HTTPI tried to use the httpclient adapter, but was unable to find the library in the LOAD_PATH.",
          "Falling back to using the #{HTTPI::Adapter::FALLBACK} adapter now."
        )
        
        adapter.find :httpclient
      end
    end
  end

end
