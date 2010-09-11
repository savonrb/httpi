require "zlib"
require "stringio"

module HTTPI
  class Response

    # Range of HTTP response codes considered to be successful.
    SuccessfulResponseCodes = 200..299

    # Initializer expects an HTTP response +code+, +headers+ and +body+.
    def initialize(code, headers, body)
      self.code = code
      self.headers = headers
      self.raw_body = body
    end

    attr_accessor :code, :headers, :raw_body

    # Returns whether the HTTP response is considered successful.
    def error?
      !SuccessfulResponseCodes.include? code.to_i
    end

    # Returns the HTTP response body.
    def body
      @body ||= gzipped_response? ? decoded_body : raw_body
    end

    attr_writer :body

  private

    # Returns whether the response is gzipped.
    def gzipped_response?
      headers["Content-Encoding"] == "gzip" || raw_body[0..1] == "\x1f\x8b"
    end

    # Returns the gzip decoded response body.
    def decoded_body
      gzip = Zlib::GzipReader.new StringIO.new(raw_body)
      gzip.read
    ensure
      gzip.close
    end

  end
end
