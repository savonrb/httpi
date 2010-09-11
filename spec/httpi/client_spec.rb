require "spec_helper"
require "httpi"

describe HTTPI::Client do

  describe ".new" do
    it "should default to use HTTPI::Adapter::DEFAULT" do
      @httpi = HTTPI::Client.new
      @httpi.client.should be_an(HTTPClient)
    end

    it "should accept an adapter to use" do
      @httpi = HTTPI::Client.new :curb
      @httpi.client.should be_a(Curl::Easy)
    end

    it "should raise an ArgumentError in case of an invalid adapter" do
      lambda { HTTPI::Client.new :unknown }.should raise_error(ArgumentError)
    end
  end

end
