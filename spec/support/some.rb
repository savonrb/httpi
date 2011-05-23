module HTTPI
  module SpecSupport

    SOME = {
      :url     => "http://example.com",
      :ssl_url => "https://example.com",
      :headers => { "Accept-Encoding" => "gzip" },
      :body    => "request body"
    }

    def some(value)
      SOME[value]
    end

  end
end
