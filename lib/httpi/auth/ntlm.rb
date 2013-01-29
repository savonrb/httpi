begin
  Kernel.require 'net/ntlm'
  Kernel.require 'kconv'

  module HTTPI
    module Auth
      module NTLM
      end
    end
  end
rescue LoadError => error
  friendly_message = "Optional dependency 'rubyntlm' not installed. "
  friendly_message << "Install with 'gem install rubyntlm' and try again."
  raise LoadError, friendly_message, caller
end
