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

      def register(adapter_class, key)
        ADAPTERS.update key => adapter_class
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
    #
    # Create your own adapter by implementing all public instance methods and calling at least
    #   register :adapter_name
    # inside the class definition. If the adapter has dependencies require the via
    #   require 'any', 'dependencies'
    # or override self.require for specialized behavior.
    class Base
      class << self
        # require all needed dependencies for this adapter to work or prepare for later requiring
        def require *args
          if args.any?
            @dependencies = args
          elsif @dependencies
            @dependencies.each { |d| Kernel.require d }
          end
        end

        # Register the adapter. Must return a symbol.
        def register name
          Adapter.register self, name
        end
      end

      def initialize(request = nil)
        abstract!
      end

      # Returns a client instance.
      def client
        abstract!
      end

      # Executes an HTTP GET request.
      # @see HTTPI.get
      def get(request)
        abstract!
      end

      # Executes an HTTP POST request.
      # @see HTTPI.post
      def post(request)
        abstract!
      end

      # Executes an HTTP HEAD request.
      # @see HTTPI.head
      def head(request)
        abstract!
      end

      # Executes an HTTP PUT request.
      # @see HTTPI.put
      def put(request)
        abstract!
      end

      # Executes an HTTP DELETE request.
      # @see HTTPI.delete
      def delete(request)
        abstract!
      end

      private

      def abstract!
        raise 'Abstract! Please implement!'
      end
    end
  end
end
