require "logger"

module HTTPI

  class << self

    # Sets whether to log HTTP requests.
    attr_writer :log

    # Returns whether to log HTTP requests. Defaults to +true+.
    def log?
      @log != false
    end

    # Sets the logger to use.
    attr_writer :logger

    # Returns the logger. Defaults to an instance of +Logger+ writing to STDOUT.
    def logger
      @logger ||= ::Logger.new($stdout)
    end

    # Sets the log level.
    attr_writer :log_level

    # Returns the log level. Defaults to :debug.
    def log_level
      @log_level ||= DEFAULT_LOG_LEVEL
    end

    # Logs a given +message+.
    def log(message)
      logger.send(log_level, message) if log?
    end

    # Reset the default config.
    def reset_config!
      @log = nil
      @logger = nil
      @log_level = nil
    end

    protected

    def log_request(method, request, adapter)
      log("HTTPI #{method.to_s.upcase} request to #{request.url.host} (#{adapter})")
    end

  end
end
