require "httpi/adapter"

module HTTPI
  module Adapter

    # HTTPI::Adapter::Base
    #
    # Allows you to build your own adapter by implementing all public instance methods.
    # Register your adapter by calling the base class' .register method.
    class Base

      # Registers an adapter.
      def self.register(name, options = {})
        deps = options.fetch(:deps, [])
        Adapter.register(name, self, deps)
      end

      def initialize(request)
      end

      # Returns a client instance.
      def client
        raise NotImplementedError, "Adapters need to implement a #client method"
      end

      # Executes arbitrary HTTP requests.
      # @see HTTPI.request
      def request(method)
        raise NotImplementedError, "Adapters need to implement a #request method"
      end

    end
  end
end
