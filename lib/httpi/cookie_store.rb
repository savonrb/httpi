module HTTPI

  # = HTTPI::CookieStore
  #
  # Stores a unique list of cookies for future requests.
  #
  # == Examples
  #
  #   # Add one or more cookies to the store
  #   cookie_store = HTTPI::CookieStore.new
  #   cookie_store.add HTTPI::Cookie.new("token=choc-choc-chip; Path=/; HttpOnly")
  #
  #   # Fetch the names and values for the "Cookie" header
  #   cookie_store.fetch  # => "token=choc-choc-chip"
  class CookieStore

    def initialize
      @cookies = {}
    end

    # Adds one or more cookies to the store.
    def add(*cookies)
      cookies.each do |cookie|
        @cookies[cookie.name] = cookie.name_and_value
      end
    end

    # Returns the names and values for the "Cookie" header.
    def fetch
      @cookies.values.join(";") unless @cookies.empty?
    end

  end
end
