require "spec_helper"
require "httpi"

describe HTTPI do
  let(:client) { HTTPI }
  let(:default_adapter) { HTTPI::Adapter.find HTTPI::Adapter.use }
  let(:curb) { HTTPI::Adapter.find :curb }

  describe ".get(request)" do
    it "should execute an HTTP GET request using the default adapter" do
      request = HTTPI::Request.new
      default_adapter.any_instance.expects(:get).with(request)
      
      client.get request
    end
  end

  describe ".get(request, adapter)" do
    it "should execute an HTTP GET request using the given adapter" do
      request = HTTPI::Request.new
      curb.any_instance.expects(:get).with(request)
      
      client.get request, :curb
    end
  end

  describe ".get(url)" do
    it "should execute an HTTP GET request using the default adapter" do
      HTTPI::Request.any_instance.expects(:url=).with("http://example.com")
      default_adapter.any_instance.expects(:get).with(instance_of(HTTPI::Request))
      
      client.get "http://example.com"
    end
  end

  describe ".get(url, adapter)" do
    it "should execute an HTTP GET request using the given adapter" do
      HTTPI::Request.any_instance.expects(:url=).with("http://example.com")
      curb.any_instance.expects(:get).with(instance_of(HTTPI::Request))
      
      client.get "http://example.com", :curb
    end
  end
  
  describe ".get" do
    context "(with a block)" do
      it "should yield the HTTP client instance used for the request" do
        client.get "http://example.com" do |http|
          http.should be_an(HTTPClient)
        end
      end
    end

    it "should raise an ArgumentError in case of an invalid adapter" do
      lambda { client.get HTTPI::Request.new, :invalid }.should raise_error(ArgumentError)
    end

    it "should raise an ArgumentError in case of an invalid URL" do
      lambda { client.get "invalid" }.should raise_error(ArgumentError)
    end
  end

  describe ".post(request)" do
    it "should execute an HTTP POST request using the default adapter" do
      request = HTTPI::Request.new
      default_adapter.any_instance.expects(:post).with(request)
      
      client.post request
    end
  end

  describe ".post(request, adapter)" do
    it "should execute an HTTP POST request using the given adapter" do
      request = HTTPI::Request.new
      curb.any_instance.expects(:post).with(request)
      
      client.post request, :curb
    end
  end

  describe ".post(url, body)" do
    it "should execute an HTTP POST request using the default adapter" do
      HTTPI::Request.any_instance.expects(:url=).with("http://example.com")
      HTTPI::Request.any_instance.expects(:body=).with("<some>xml</some>")
      default_adapter.any_instance.expects(:post).with(instance_of(HTTPI::Request))
      
      client.post "http://example.com", "<some>xml</some>"
    end
  end

  describe ".post(url, body, adapter)" do
    it "should execute an HTTP POST request using the given adapter" do
      HTTPI::Request.any_instance.expects(:url=).with("http://example.com")
      HTTPI::Request.any_instance.expects(:body=).with("<some>xml</some>")
      curb.any_instance.expects(:post).with(instance_of(HTTPI::Request))
      
      client.post "http://example.com", "<some>xml</some>", :curb
    end
  end

  describe ".post" do
    context "(with a block)" do
      it "should yield the HTTP client instance used for the request" do
        client.get "http://example.com", :curb do |http|
          http.should be_a(Curl::Easy)
        end
      end
    end

    it "should raise an ArgumentError in case of an invalid adapter" do
      lambda { client.post HTTPI::Request.new, :invalid }.should raise_error(ArgumentError)
    end

    it "should raise an ArgumentError in case of an invalid URL" do
      lambda { client.post "invalid" }.should raise_error(ArgumentError)
    end
  end

end
