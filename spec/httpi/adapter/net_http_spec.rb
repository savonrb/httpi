require "spec_helper"
require "httpi/adapter/net_http"
require "httpi/request"

begin
  HTTPI::Adapter.load_adapter(:net_http)

  describe HTTPI::Adapter::NetHTTP do
    let(:adapter) { HTTPI::Adapter::NetHTTP.new(request) }
    let(:request) { HTTPI::Request.new("http://example.com") }

    let(:response) {
      Object.new.tap do |r|
        r.stubs(:code).returns(200)
        r.stubs(:body).returns("abc")
        r.stubs(:to_hash).returns({"Content-Length" => "3"})
      end
    }

    before do
      Net::HTTP.any_instance.stubs(:start).returns(response)
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
        if Net::HTTP.method_defined?(:write_timeout=)
          it "is being set on the client" do
            request.write_timeout = 50
            adapter.client.expects(:write_timeout=).with(50)
            adapter.request(:get)
          end
        else
          it "can not be set on the client" do
            request.write_timeout = 50
            expect { adapter.request(:get) }
              .to raise_error(HTTPI::NotSupportedError, /write_timeout/)
          end
        end
      end
    end
  end
end
