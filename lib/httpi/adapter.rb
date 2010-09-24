require "httpi/adapter/httpclient"
require "httpi/adapter/curb"

module HTTPI

  # = HTTPI::Adapter
  #
  # Manages the adapter classes. Currently supports:
  #
  # * httpclient
  # * curb
  module Adapter

    # The default adapter.
    DEFAULT = :httpclient

    # Returns the adapter to use. Defaults to <tt>HTTPI::Adapter::DEFAULT</tt>.
    def self.use
      @use ||= DEFAULT
    end

    # Sets the +adapter+ to use. Raises an +ArgumentError+ unless the +adapter+ exists.
    def self.use=(adapter)
      validate_adapter! adapter
      @use = adapter
    end

    # Returns a memoized +Hash+ of adapters.
    def self.adapters
      @adapters ||= { :httpclient => HTTPClient, :curb => Curb }
    end

    # Returns an +adapter+. Raises an +ArgumentError+ unless the +adapter+ exists.
    def self.find(adapter)
      validate_adapter! adapter
      adapters[adapter]
    end

  private

    # Raises an +ArgumentError+ unless the +adapter+ exists.
    def self.validate_adapter!(adapter)
      raise ArgumentError, "Invalid HTTPI adapter: #{adapter}" unless adapters[adapter]
    end

  end
end
