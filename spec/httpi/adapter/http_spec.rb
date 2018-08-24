require "spec_helper"
require "httpi/adapter/http"
require "httpi/request"

begin
  HTTPI::Adapter.load_adapter(:http)

  describe HTTPI::Adapter::HTTP do
    let(:adapter) { HTTPI::Adapter::HTTP.new(request) }
    let(:request) { HTTPI::Request.new("http://example.com") }

    describe "settings" do
      describe "connect_timeout, read_timeout, write_timeout" do
        it "are being set on the client" do
          request.open_timeout = 30
          request.read_timeout = 40
          request.write_timeout = 50

          expect(adapter.client.default_options.timeout_options).to eq(
            connect_timeout: 30,
            read_timeout: 40,
            write_timeout: 50
          )
        end
      end
    end
  end
end
