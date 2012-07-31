require 'httpi/auth/config'

module HTTPI
  # To create a custom auth method subclass HTTPI::Auth::Base
  # and call
  #   register :auth_name
  # inside the class definition.
  #
  # Calling request.auth.auth_name(init, params) will create an instance of your
  # auth class and set request.auth to this instance.
  #
  # TODO Example
  module Auth
    # register new authentication method
    def self.register klass, name
      Config::TYPES.update klass => name
      Config.class_eval do
        define_method(name) do |*args|
          @auth = klass.new(*args) if args.any?
          @auth ||= klass.new
        end
        define_method("#{name}?") do
          @auth.is_a? klass
        end
      end
    end

    class Base
      class << self
        def register name
          Auth.register self, name
        end
      end
    end
  end
end
