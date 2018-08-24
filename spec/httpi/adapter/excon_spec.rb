require "spec_helper"
require "httpi/adapter/excon"
require "httpi/request"

begin
  HTTPI::Adapter.load_adapter(:excon)

  describe HTTPI::Adapter::Excon do
    let(:adapter) { HTTPI::Adapter::Excon.new(request) }
    let(:request) { HTTPI::Request.new("http://example.com") }

    describe "settings" do
      describe "connect_timeout, read_timeout, write_timeout" do
        it "are passed as connection options" do
          request.open_timeout = 30
          request.read_timeout = 40
          request.write_timeout = 50

          expect(adapter.client.data).to include(
            connect_timeout: 30,
            read_timeout: 40,
            write_timeout: 50
          )
        end
      end
    end
  end
end
