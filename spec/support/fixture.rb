module HTTPI
  module SpecSupport

    FIXTURES = {
      :xml      => "xml.xml",
      :xml_dime => "xml_dime.xml",
      :gzip     => "xml.gz",
      :dime     => "xml_dime.dime"
    }

    def fixture(fixture)
      File.read File.expand_path("../../fixtures/#{FIXTURES[fixture]}", __FILE__)
    end

  end
end
