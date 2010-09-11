class Some
  class << self

    def url
      @url ||= "http://example.com"
    end

    def headers
      @headers ||= { "Content-Type" => "text/html; charset=utf-8" }
    end

    def response_code
      @code ||= 200
    end

  end
end

class Fixture
  class << self

    def xml
      @xml ||= load :xml
    end

    def gzip
      @gzip ||= load :gzip, :gz
    end

  private

    def load(fixture, type = :xml)
      File.read File.expand_path("../../fixtures/#{fixture}.#{type}", __FILE__)
    end

  end
end
