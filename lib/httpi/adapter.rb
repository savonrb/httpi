require "httpi/adapter/httpclient"
require "httpi/adapter/curb"
require "httpi/adapter/net_http"

module HTTPI

  # = HTTPI::Adapter
  #
  # Manages the adapter classes. Currently supports:
  #
  # * httpclient
  # * curb
  # * net/http
  module Adapter

    ADAPTERS = {
      :httpclient => HTTPClient,
      :curb       => Curb,
      :net_http   => NetHTTP
    }

    DEPENDENCIES = [
      [:httpclient, ["httpclient"]],
      [:curb,       ["curb"]],
      [:net_http,   ["net/https", "net/ntlm_http"]]
    ]

    class << self

      def use=(adapter)
        @adapter = adapter.nil? ? nil : validate_adapter!(adapter)
      end

      def use
        @adapter ||= default_adapter
      end

      def load(adapter = nil)
        adapter = adapter ? validate_adapter!(adapter) : use
        [adapter, ADAPTERS[adapter]]
      end

    private

      def validate_adapter!(adapter)
        raise ArgumentError, "Invalid HTTPI adapter: #{adapter}" unless ADAPTERS[adapter]
        adapter
      end

      def default_adapter
        return :httpclient if defined?(::HTTPClient)
        return :curb if defined?(::Curl::Easy)
        return :net_http if defined?(::Net::HTTP)

        DEPENDENCIES.each do |(adapter, dependencies)|
          begin
            dependencies.each { |dependency| require dependency }
            return adapter
          rescue LoadError
            next
          end
        end
      end

    end
  end
end
