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
      :httpclient => { :class => HTTPClient, :dependencies => ["httpclient"] },
      :curb       => { :class => Curb,       :dependencies => ["curb"] },
      :net_http   => { :class => NetHTTP,    :dependencies => ["net/https", "net/ntlm_http"] }
    }

    LOAD_ORDER = [:httpclient, :curb, :net_http]

    class << self

      def use=(adapter)
        return @adapter = nil if adapter.nil?

        validate_adapter! adapter
        load_dependencies adapter
        @adapter = adapter
      end

      def use
        @adapter ||= default_adapter
      end

      def load(adapter)
        adapter = adapter ? validate_adapter!(adapter) : use
        [adapter, ADAPTERS[adapter][:class]]
      end

    private

      def validate_adapter!(adapter)
        raise ArgumentError, "Invalid HTTPI adapter: #{adapter}" unless ADAPTERS[adapter]
        adapter
      end

      def default_adapter
        LOAD_ORDER.each do |adapter|
          begin
            load_dependencies adapter
            return adapter
          rescue LoadError
            next
          end
        end
      end

      def load_dependencies(adapter)
        ADAPTERS[adapter][:dependencies].each { |dependency| require dependency }
      end

    end
  end
end
