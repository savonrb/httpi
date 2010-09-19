class Fixture
  class << self

    def xml
      @xml ||= load :xml
    end

    def gzip
      @gzip ||= load :xml, :gz
    end

  private

    def load(fixture, type = :xml)
      File.read File.expand_path("../../fixtures/#{fixture}.#{type}", __FILE__)
    end

  end
end
