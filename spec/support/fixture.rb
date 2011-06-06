module HTTPI
  module SpecSupport

    FIXTURES = {
      :xml      => "xml.xml",
      :xml_dime => "xml_dime.xml",
      :gzip     => "xml.gz",
      :dime     => "xml_dime.dime"
    }

    def fixture(fixture)
      file = FIXTURES[fixture]
      raise "No such fixture: #{file}" unless file

      File.read File.expand_path("../../fixtures/#{file}", __FILE__)
    end

  end
end
