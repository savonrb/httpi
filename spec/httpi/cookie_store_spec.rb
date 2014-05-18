require "spec_helper"
require "httpi"

describe HTTPI::CookieStore do

  let(:user_cookie)  { some_cookie(:user, "chucknorris") }
  let(:token_cookie) { some_cookie(:token, "strawberry") }

  it "stores a set of cookies" do
    cookie_store = HTTPI::CookieStore.new
    cookie_store.add(user_cookie, token_cookie)
    expect(cookie_store.fetch).to include("user=chucknorris", "token=strawberry")

    # add a new token cookie with a different value
    token_cookie = some_cookie(:token, "choc-choc-chip")
    cookie_store.add(token_cookie)

    expect(cookie_store.fetch).to include("token=choc-choc-chip")
    expect(cookie_store.fetch).not_to include("token=strawberry")
  end

  def some_cookie(name, value)
    HTTPI::Cookie.new("#{name}=#{value}; Path=/; HttpOnly")
  end

end
