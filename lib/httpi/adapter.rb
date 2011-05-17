
module HTTPI

  # = HTTPI::Adapter
  #
  # Manages the adapter classes. Currently supports:
  #
  # * httpclient
  # * curb
  # * net/http
  module Adapter

    class << self

      def adapters
        @adapters ||= {}
      end

      def use=(adapter)
        return @adapter = nil if adapter.nil?

        validate_adapter! adapter
        load_dependencies adapter
        @adapter = adapter
      end

      def use
        @adapter
      end

    private

      def validate_adapter!(adapter)
        raise ArgumentError, "Invalid HTTPI adapter: #{adapter}" unless adapters.key?(adapter)
        adapter
      end

      def load_dependencies(adapter)
        adapters[adapter][:dependencies].each { |dependency| require dependency }
      end

    end
  end
end
require "httpi/adapter/net_http"
