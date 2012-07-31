module HTTPI
  module Auth

    class BasicObject
      instance_methods.each do |m|
        undef_method(m) if m.to_s !~ /(?:^__|^nil?$|^send$|^object_id$)/
      end
    end unless defined?(BasicObject)

    # = HTTPI::Auth::Config
    #
    # Proxy object that delegates to Auth classes
    class Config < BasicObject
      # Registered authentication types.
      TYPES = {}

      # Accessor for the authentication type in use.
      def type
        TYPES[@auth.class]
      end

      def method_missing name, *args, &block
        @auth.send name, *args, &block
      end
    end
  end
end
