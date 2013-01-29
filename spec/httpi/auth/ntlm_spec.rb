require "spec_helper"

describe "HTTPI::Auth::NTLM" do

  describe "with rubyntlm gem, NOT installed" do
    it "should raise LoadError with friendly message" do
      Kernel.expects(:require).with('net/ntlm').raises(LoadError, "Mock load error :P")
      load_error = nil
      begin
        require "httpi/auth/ntlm"
      rescue LoadError => error
        load_error = error
      end

      load_error.should_not be_nil
      load_error.message.should match(/rubyntlm/)
    end
  end

  describe "with rubyntlm gem installed" do
    it "before require, NTLM should not be defined" do
      defined?(HTTPI::Auth::NTLM).should be_false
    end
    it "after require, NTLM should be defined" do
      require "httpi/auth/ntlm"
      defined?(HTTPI::Auth::NTLM).should_not be_false
    end
  end

end
