require 'httpi/auth/config'

module HTTPI
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
  end
end
