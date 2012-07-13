module HTTPI

  # = HTTPI::Adapter
  #
  # Manages the adapter classes. Currently supports:
  #
  # * httpclient
  # * curb
  # * net/http
  module Adapter

    ADAPTERS = {}
    LOAD_ORDER = [:httpclient, :curb, :net_http]

    class << self

      def register(adapter_class)
        ADAPTERS.update adapter_class.to_sym => adapter_class
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

      def load(adapter)
        adapter = adapter ? validate_adapter!(adapter) : use
        [adapter, ADAPTERS[adapter]]
      end

    private

      def validate_adapter!(adapter)
        raise ArgumentError, "Invalid HTTPI adapter: #{adapter}" unless ADAPTERS[adapter]
        adapter
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

      def load_adapter adapter
        ADAPTERS[adapter].require
      end

    end

    # Adapter class interface
    class Base
      # Should return a symbol by which the adapter is referred to
      def self.to_sym
        raise 'Abstract! Please implement!'
      end

      # require all needed dependencies for this adapter to work
      def self.require
        raise 'Abstract! Please implement!'
      end

      # TODO spec out the interface
    end
  end
end
