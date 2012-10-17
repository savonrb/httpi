require "zlib"
require "stringio"
require "rack/utils"

require "httpi/dime"
require "httpi/cookie"

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
      self.headers = Rack::Utils::HeaderHash.new(headers)
      self.raw_body = body
    end

    attr_accessor :code, :headers, :raw_body, :attachments

    # Returns whether the HTTP response is considered successful.
    def error?
      !SuccessfulResponseCodes.include? code.to_i
    end

    # Returns whether the HTTP response is a multipart response.
    def multipart?
      !!(headers["Content-Type"] =~ /^multipart/i)
    end

    # Returns a list of cookies from the response.
    def cookies
      @cookies ||= Cookie.list_from_headers(headers)
    end

    # Returns any DIME attachments.
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
      return @body = "" if !raw_body || raw_body.empty?

      body = gzipped_response? ? decoded_gzip_body : raw_body
      @body = dime_response? ? decoded_dime_body(body) : body
    end

    # Returns whether the response is gzipped.
    def gzipped_response?
      headers["Content-Encoding"] == "gzip"
    end

    # Returns whether this is a DIME response.
    def dime_response?
      headers["Content-Type"] == "application/dime"
    end

    # Returns the gzip decoded response body.
    def decoded_gzip_body
      unless gzip = Zlib::GzipReader.new(StringIO.new(raw_body))
        raise ArgumentError, "Unable to create Zlib::GzipReader"
      end
      gzip.read
    ensure
      gzip.close if gzip
    end

    # Returns the DIME decoded response body.
    def decoded_dime_body(body = nil)
      dime = Dime.new(body || raw_body)
      self.attachments = dime.binary_records
      dime.xml_records.first.data
    end

  end
end
