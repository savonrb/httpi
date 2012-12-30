require "spec_helper"
require "httpi/adapter/base"

describe HTTPI::Adapter::Base do

  subject(:base) { HTTPI::Adapter::Base.new(request) }
  let(:request)  { HTTPI::Request.new }

  describe "#client" do
    it "returns the adapter's client instance" do
      expect { base.client }.
        to raise_error(HTTPI::NotImplementedError, "Adapters need to implement a #client method")
    end
  end

  describe "#request" do
    it "executes arbitrary HTTP requests" do
      expect { base.request(:get) }.
        to raise_error(HTTPI::NotImplementedError, "Adapters need to implement a #request method")
    end
  end

end
