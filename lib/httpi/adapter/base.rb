module HTTPI
  module Adapter
    module Base

      # List of methods expected to be implemented by an adapter.
      METHODS = %w(setup client headers headers= proxy proxy= get post auth)

      METHODS.each do |method|
        define_method method do |*args|
          raise NotImplementedError, "#{Adapter.use} does not implement a #{method} method"
        end
      end

    end
  end
end
