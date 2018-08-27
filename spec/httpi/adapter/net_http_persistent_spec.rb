require "spec_helper"
require "httpi/adapter/net_http_persistent"
require "httpi/request"

begin
  HTTPI::Adapter.load_adapter(:net_http_persistent)

  describe HTTPI::Adapter::NetHTTPPersistent do
    let(:adapter) { HTTPI::Adapter::NetHTTPPersistent.new(request) }
    let(:request) { HTTPI::Request.new("http://example.com") }

    let(:response) {
      Object.new.tap do |r|
        r.stubs(:code).returns(200)
        r.stubs(:body).returns("abc")
        r.stubs(:to_hash).returns({"Content-Length" => "3"})
      end
    }

    before do
      Net::HTTP::Persistent.any_instance.stubs(:start).returns(response)
    end

    describe "settings" do
      describe "open_timeout, read_timeout" do
        it "are being set on the client" do
          request.open_timeout = 30
          request.read_timeout = 40

          adapter.client.expects(:open_timeout=).with(30)
          adapter.client.expects(:read_timeout=).with(40)

          adapter.request(:get)
        end
      end

      describe "write_timeout" do
        it "is not supported" do
          request.write_timeout = 50
          expect { adapter.request(:get) }
            .to raise_error(HTTPI::NotSupportedError, /write_timeout/)
        end
      end
    end
  end
end
