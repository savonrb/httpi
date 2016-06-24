require "spec_helper"
require "integration/support/server"

require "composite_io"

describe HTTPI::Adapter::NetHTTPMultipart do

  subject(:adapter) { :net_http_multipart }

  describe "Net::HTTP with multipart data" do
    before :all do
      @server = IntegrationServer.run
    end

    after :all do
      @server.stop
    end

    it "executes POST requests with attachments" do
      # create some IO
      buffer = StringIO.new('hello world')

      # create attachments hash
      attachments = { "file" => UploadIO.new(buffer, 'text/plain') }

      # create request with attachments
      request = HTTPI::Request.new(url: @server.url + "/attachments", attachments: attachments)

      # perform request
      response = HTTPI.post(request, adapter)

      # run tests
      expect(response.body).to eq("files: #{attachments.keys.join(',')}")
      expect(response.headers["Content-Type"]).to eq("text/plain")
    end

    it "executes PUT requests with attachments" do
      # create some IO
      buffer = StringIO.new('hello world')

      # create attachments hash
      attachments = { "file" => UploadIO.new(buffer, 'text/plain') }

      # create request with attachments
      request = HTTPI::Request.new(url: @server.url + "/attachments", attachments: attachments)

      # perform request
      response = HTTPI.put(request, adapter)

      # run tests
      expect(response.body).to eq("files: #{attachments.keys.join(',')}")
      expect(response.headers["Content-Type"]).to eq("text/plain")
    end
  end

end
