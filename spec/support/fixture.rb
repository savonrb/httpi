class Fixture
  class << self

    def xml
      @xml ||= load :xml
    end

    def xml_dime
      @xml_dime ||= load :xml_dime
    end

    def gzip
      @gzip ||= load :xml, :gz
    end

    def dime
      @dime ||= load :xml_dime, :dime
    end

  private

    def load(fixture, type = :xml)
      File.read File.expand_path("../../fixtures/#{fixture}.#{type}", __FILE__)
    end

  end
end
