require "spec_helper"

describe HTTPI do

  let(:adapter_class) do
    Class.new do
      def initialize(request)
      end
    end
  end

  let(:adapter) do
    adapter_class.any_instance
  end

  before do
    HTTPI.adapter = adapter_class
  end

  describe ".adapter?" do
    it "returns whether an adapter was specified" do
      HTTPI.adapter?.should == adapter_class
    end
  end

  HTTPI::REQUEST_METHODS.each do |method|
    describe ".#{method}" do
      it "accepts a request" do
        request = HTTPI::Request.new(some(:url))
        adapter.expects(method).with(request)

        HTTPI.send(method, request)
      end

      it "accepts a url" do
        expect_to_be_set(:url, some(:url))
        adapter.expects(method).with(instance_of(HTTPI::Request))

        HTTPI.send(method, some(:url))
      end

      it "accepts a url and headers" do
        expect_to_be_set(:url, some(:url))
        expect_to_be_set(:headers, some(:headers))
        adapter.expects(method).with(instance_of(HTTPI::Request))

        HTTPI.send(method, some(:url), some(:headers))
      end

      it "accepts a url, headers and a body" do
        expect_to_be_set(:url, some(:url))
        expect_to_be_set(:headers, some(:headers))
        expect_to_be_set(:body, some(:body))
        adapter.expects(method).with(instance_of(HTTPI::Request))

        HTTPI.send(method, some(:url), some(:headers), some(:body))
      end
    end
  end

  describe ".request" do
    it "raises in case of an invalid request method" do
      expect { HTTPI.request :invalid, HTTPI::Request.new }.
        to raise_error(ArgumentError, "Unknown request method: invalid")
    end
  end

  HTTPI::REQUEST_METHODS.each do |method|
    describe ".request(:#{method}, *args)" do
      it "delegates to the .#{method} method" do
        args = [some(:url), some(:headers), some(:body)]

        HTTPI.expects(method).with(*args)
        HTTPI.request(method, *args)
      end
    end
  end

  def expect_to_be_set(attribute, value)
    HTTPI::Request.any_instance.expects("#{attribute}=").with(value)
  end

end
