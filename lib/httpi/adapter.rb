
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

      def load(adapter)
        adapter = adapter ? validate_adapter!(adapter) : use
        if adapter
          [adapter, adapters[adapter][:class] ]
        else
          []
        end
      end

    private

      def validate_adapter!(adapter)
        raise ArgumentError, "Invalid HTTPI adapter: #{adapter}" unless adapters[adapter]
        adapter
      end

      def default_adapter
        :net_http
      end

      def load_dependencies(adapter)
        adapters[adapter][:dependencies].each { |dependency| require dependency }
      end

    end
  end
end
require "httpi/adapter/net_http"
