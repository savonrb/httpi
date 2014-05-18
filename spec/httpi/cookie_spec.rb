require "spec_helper"
require "httpi"

describe HTTPI::Cookie do

  let(:cookie) { HTTPI::Cookie.new("token=choc-choc-chip; Path=/; HttpOnly") }

  describe ".list_from_headers" do
    it "returns a list of cookies from a Hash of headers" do
      headers = { "Set-Cookie" => "token=strawberry; Path=/; HttpOnly" }
      cookies = HTTPI::Cookie.list_from_headers(headers)

      expect(cookies.size).to eq(1)
      expect(cookies.first).to be_a(HTTPI::Cookie)
    end

    it "handles multiple cookies" do
      headers = { "Set-Cookie" => ["user=chucknorris; Path=/; HttpOnly", "token=strawberry; Path=/; HttpOnly"] }
      cookies = HTTPI::Cookie.list_from_headers(headers)
      expect(cookies.size).to eq(2)
    end
  end

  describe "#name" do
    it "returns the name of the cookie" do
      expect(cookie.name).to eq("token")
    end
  end

  describe "#name_and_value" do
    it "returns the name and value of the cookie" do
      expect(cookie.name_and_value).to eq("token=choc-choc-chip")
    end
  end

end
