require "zlib"
require "stringio"
require "httpi/dime"

module HTTPI

  # = HTTPI::Response
  #
  # Represents an HTTP response and contains various response details.
  class Response

    # Range of HTTP response codes considered to be successful.
    SuccessfulResponseCodes = 200..299

    # Initializer expects an HTTP response +code+, +headers+ and +body+.
    def initialize(code, headers, body)
      self.code = code.to_i
      self.headers = headers
      self.raw_body = body
    end

    attr_accessor :code, :headers, :raw_body, :attachments

    # Returns whether the HTTP response is considered successful.
    def error?
      !SuccessfulResponseCodes.include? code.to_i
    end

    def attachments
      decode_body unless @body
      @attachments ||= []
    end

    # Returns the HTTP response body.
    def body
      decode_body unless @body
      @body
    end

    attr_writer :body

  private

    def decode_body
      body = gzipped_response? ? decoded_gzip_body : raw_body
      @body = dime_response? ? decoded_dime_body(body) : body
    end

    # Returns whether the response is gzipped.
    def gzipped_response?
      headers["Content-Encoding"] == "gzip" || raw_body[0..1] == "\x1f\x8b"
    end

    # Returns whether this is a DIME response.
    def dime_response?
      headers['Content-Type'] == 'application/dime'
    end

    # Returns the gzip decoded response body.
    def decoded_gzip_body
      gzip = Zlib::GzipReader.new StringIO.new(raw_body)
      gzip.read
    ensure
      gzip.close
    end

    # Returns the DIME decoded response body.
    def decoded_dime_body(body = nil)
      dime = Dime.new(body || raw_body)
      self.attachments = dime.binary_records
      dime.xml_records.first.data
    end

  end
end
