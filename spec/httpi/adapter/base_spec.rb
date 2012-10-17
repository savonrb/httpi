require "spec_helper"
require "httpi/adapter/base"

describe HTTPI::Adapter::Base do

  subject(:base) { HTTPI::Adapter::Base }
  let(:request)  { HTTPI::Request.new }

  describe "#initialize" do
    it "accepts an HTTPI::Request" do
      expect { base.new(request) }.
        to raise_error(HTTPI::NotImplementedError, "Adapters need to implement an #initialize method")
    end
  end

  describe "#client" do
    it "returns the adapter's client instance" do
      expect { base.new.client }.
        to raise_error(HTTPI::NotImplementedError, "Adapters need to implement a #client method")
    end
  end

  describe "#request" do
    it "executes arbitrary HTTP requests" do
      expect { base.new.request(:get, request) }.
        to raise_error(HTTPI::NotImplementedError, "Adapters need to implement a #request method")
    end
  end

end
