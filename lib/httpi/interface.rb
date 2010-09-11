require "httpi/adapter"

module HTTPI
  module Interface

    # Loads a given +adapter+. Defaults to load <tt>HTTPI::Adapter::DEFAULT</tt>.
    def load!(adapter = nil)
      adapter ||= Adapter.use
      include_adapter Adapter.find(adapter)
      setup
    end

  private

    # Includes a given +adapter+ into the current class.
    def include_adapter(adapter)
      self.class.send :include, adapter
    end

  end
end
