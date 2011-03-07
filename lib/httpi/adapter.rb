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

    # The default adapter.
    DEFAULT = :httpclient

    # The fallback (worst-choice) adapter.
    FALLBACK = :net_http

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
      @adapters ||= {
        :httpclient => { :class => HTTPClient, :require => ["httpclient"] },
        :curb       => { :class => Curb,       :require => ["curb"] },
        :net_http   => { :class => NetHTTP,    :require => ["net/https", "net/ntlm_http"] }
      }
    end

    # Returns an +adapter+. Raises an +ArgumentError+ unless the +adapter+ exists.
    def self.find(adapter)
      validate_adapter! adapter
      load_adapter adapter
    end

  private

    # Raises an +ArgumentError+ unless the +adapter+ exists.
    def self.validate_adapter!(adapter)
      raise ArgumentError, "Invalid HTTPI adapter: #{adapter}" unless adapters[adapter]
    end

    # Tries to load and return the given +adapter+ name and class and falls back to the +FALLBACK+ adapter.
    def self.load_adapter(adapter)
      adapters[adapter][:require].each { |dependency| require dependency }
      [adapter, adapters[adapter][:class]]
    rescue LoadError
      HTTPI.logger.warn "HTTPI tried to use the #{adapter} adapter, but was unable to find the library in the LOAD_PATH.",
        "Falling back to using the #{FALLBACK} adapter now."

      require adapters[FALLBACK][:require]
      [FALLBACK, adapters[FALLBACK][:class]]
    end

  end
end
