require "spec_helper"
require "httpi"

describe HTTPI::Cookie do

  let(:cookie) { HTTPI::Cookie.new("token=choc-choc-chip; Path=/; HttpOnly") }

  describe ".list_from_headers" do
    it "returns a list of cookies from a Hash of headers" do
      headers = { "Set-Cookie" => "token=strawberry; Path=/; HttpOnly" }
      cookies = HTTPI::Cookie.list_from_headers(headers)

      cookies.should have(1).item
      cookies.first.should be_a(HTTPI::Cookie)
    end

    it "handles multiple cookies" do
      headers = { "Set-Cookie" => ["user=chucknorris; Path=/; HttpOnly", "token=strawberry; Path=/; HttpOnly"] }
      cookies = HTTPI::Cookie.list_from_headers(headers)
      cookies.should have(2).items
    end
  end

  describe "#name" do
    it "returns the name of the cookie" do
      cookie.name.should == "token"
    end
  end

  describe "#name_and_value" do
    it "returns the name and value of the cookie" do
      cookie.name_and_value.should == "token=choc-choc-chip"
    end
  end

end
