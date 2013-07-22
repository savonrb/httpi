module HTTPI

  # = HTTPI::Adapter
  #
  # Manages the adapter classes. Currently supports:
  #
  # * httpclient
  # * curb
  # * em_http
  # * net/http
  module Adapter

    ADAPTERS = {}
    ADAPTER_CLASS_MAP = {}

    LOAD_ORDER = [:httpclient, :curb, :em_http, :excon, :net_http, :net_http_persistent]

    class << self

      def register(name, adapter_class, deps)
        ADAPTERS[name] = { :class => adapter_class, :deps => deps }
        ADAPTER_CLASS_MAP[adapter_class] = name
      end

      def use=(adapter)
        return @adapter = nil if adapter.nil?

        validate_adapter! adapter
        load_adapter adapter
        @adapter = adapter
      end

      def use
        @adapter ||= default_adapter
      end

      def identify(adapter_class)
        ADAPTER_CLASS_MAP[adapter_class]
      end

      def load(adapter)
        adapter ||= use

        validate_adapter!(adapter)
        load_adapter(adapter)
        ADAPTERS[adapter][:class]
      end

      def load_adapter(adapter)
        ADAPTERS[adapter][:deps].each do |dep|
          require dep
        end
      end

      private

      def validate_adapter!(adapter)
        raise ArgumentError, "Invalid HTTPI adapter: #{adapter}" unless ADAPTERS[adapter]
      end

      def default_adapter
        LOAD_ORDER.each do |adapter|
          begin
            load_adapter adapter
            return adapter
          rescue LoadError
            next
          end
        end
      end

    end
  end
end
