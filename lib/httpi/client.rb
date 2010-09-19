require "httpi/adapter"

module HTTPI
  class Client
    class << self

      # Expects an <tt>HTTPI::Request</tt> and an optional +adapter+ to
      # execute an HTTP GET request. Returns an <tt>HTTPI::Response</tt>.
      def get(request, adapter = nil)
        find_adapter(adapter).get request
      end

      # Expects an <tt>HTTPI::Request</tt> and an optional +adapter+ to
      # execute an HTTP POST request. Returns an <tt>HTTPI::Response</tt>.
      def post(request, adapter = nil)
        find_adapter(adapter).post request
      end

    private

      # Accepts an +adapter+ (defaults to <tt>Adapter.use</tt>) and returns
      # a new instance of the adapter to use.
      def find_adapter(adapter)
        adapter ||= Adapter.use
        Adapter.find(adapter).new
      end

    end
  end
end
