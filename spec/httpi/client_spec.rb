require "spec_helper"
require "httpi"

describe HTTPI::Client do
  let(:client) { HTTPI::Client }

  describe ".get" do
    it "should execute an HTTP GET request using the default adapter" do
      adapter = HTTPI::Adapter.find HTTPI::Adapter.use
      request = HTTPI::Request.new
      
      adapter.any_instance.expects(:get).with(request)
      client.get request
    end

    it "should execute an HTTP GET request using the given adapter" do
      adapter = HTTPI::Adapter.find :curb
      request = HTTPI::Request.new

      adapter.any_instance.expects(:get).with(request)
      client.get request, :curb
    end

    it "should raise an ArgumentError in case of an invalid adapter" do
      lambda { client.get HTTPI::Request.new, :invalid }.should raise_error(ArgumentError)
    end
 end

  describe ".post" do
    it "should execute an HTTP POST request using the default adapter" do
      adapter = HTTPI::Adapter.find HTTPI::Adapter.use
      request = HTTPI::Request.new
      
      adapter.any_instance.expects(:post).with(request)
      client.post request
    end

    it "should execute an HTTP POST request using the given adapter" do
      adapter = HTTPI::Adapter.find :curb
      request = HTTPI::Request.new

      adapter.any_instance.expects(:post).with(request)
      client.post request, :curb
    end

    it "should raise an ArgumentError in case of an invalid adapter" do
      lambda { client.post HTTPI::Request.new, :invalid }.should raise_error(ArgumentError)
    end
 end

end
