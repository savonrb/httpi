require "spec_helper"
require "httpi/interface"

describe HTTPI::Interface do

  context "when included" do
    before do
      @httpi = Class.new { include HTTPI::Interface }.new
    end

    it "should offer a #load! method for loading an adapter" do
      @httpi.load!
      @httpi.client.should be_an(HTTPClient)
    end

    describe "#load!" do
      it "should accept an adapter to use" do
        @httpi.load! :curb
        @httpi.client.should be_a(Curl::Easy)
      end

      it "should raise an ArgumentError in case of an invalid adapter" do
        lambda { @httpi.load! :unknown }.should raise_error(ArgumentError)
      end

      it "should call the adapter's #setup method" do
        @httpi.expects(:setup)
        @httpi.load!
      end
    end
  end

end
