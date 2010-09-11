require "httpi/interface"

module HTTPI
  class Client
    include Interface

    def initialize(adapter = nil)
      load! adapter
    end

  end
end
