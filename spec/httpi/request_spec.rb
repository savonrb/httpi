require "spec_helper"
require "httpi/request"

describe HTTPI::Request do
  let(:request) { HTTPI::Request.new }

  describe ".new" do
    it "accepts a url" do
      request = HTTPI::Request.new "http://example.com"
      expect(request.url).to eq(URI("http://example.com"))
    end

    it "accepts a Hash of accessors to set" do
      request = HTTPI::Request.new :url => "http://example.com", :open_timeout => 30, :query => { key: "value" }
      expect(request.url).to eq(URI("http://example.com?key=value"))
      expect(request.open_timeout).to eq(30)
      expect(request.query).to eq("key=value")
    end
  end

  describe "#url" do
    it "lets you specify the URL to access as a String" do
      request.url = "http://example.com"
      expect(request.url).to eq(URI("http://example.com"))
    end

    it "also accepts a URI object" do
      request.url = URI("http://example.com")
      expect(request.url).to eq(URI("http://example.com"))
    end

    it "raises an ArgumentError in case of an invalid url" do
      expect { request.url = "invalid" }.to raise_error(ArgumentError)
    end

    it "uses username and password as basic authentication if present in the URL" do
      request.url = "http://username:password@example.com"
      expect(request.auth.basic).to eq(['username', 'password'])
    end

    it "uses a blank password if only username is specified in the URL" do
      request.url = "http://username@example.com"
      expect(request.auth.basic).to eq(['username', ''])
    end
  end

  describe "#query" do
    it "raises an ArgumentError if url not respond to query" do
      expect { request.query = "q=query" }.to raise_error(ArgumentError)
    end

    it "getter return nil for invalid url" do
      expect(request.query).to be_nil
    end

    context "with query parameter as String" do
      it "lets you specify query parameter as String" do
        request.url = "http://example.com"
        request.query = "q=query"
        expect(request.url.to_s).to eq("http://example.com?q=query")
      end

      it "getter return String for query parameter as String" do
        request.url = "http://example.com"
        request.query = "q=query"
        expect(request.query).to eq("q=query")
      end
    end

    context "with query parameter as Hash" do
      context "with flat query builder" do
        before do
          request.url = "http://example.com"
          request.query = {:q => ["nested", "query"]}
        end

        it "lets you specify query parameter as Hash" do
          expect(request.url.to_s).to eq("http://example.com?q=nested&q=query")
        end

        it "getter return String for query parameter as Hash" do
          expect(request.query).to eq("q=nested&q=query")
        end
      end
      context "with nested query builder" do
        before do
          HTTPI.query_builder = :nested

          request.url = "http://example.com"
          request.query = {:q => ["nested", "query"]}
        end
        after { HTTPI.query_builder = :flat }

        it "lets you specify query parameter as Hash" do
          expect(request.url.to_s).to eq("http://example.com?q[]=nested&q[]=query")
        end

        it "getter return String for query parameter as Hash" do
          expect(request.query).to eq("q[]=nested&q[]=query")
        end
      end
    end
  end

  describe "#proxy" do
    it "lets you specify the proxy URL to use as a String" do
      request.proxy = "http://proxy.example.com"
      expect(request.proxy).to eq(URI("http://proxy.example.com"))
    end

    it "also accepts a URI object" do
      request.proxy = URI("http://proxy.example.com")
      expect(request.proxy).to eq(URI("http://proxy.example.com"))
    end

    it "raises an ArgumentError in case of an invalid url" do
      expect { request.proxy = "invalid" }.to raise_error(ArgumentError)
    end
  end

  describe "#ssl" do
    it "returns false if no request url was specified" do
      expect(request).not_to be_ssl
    end

    it "returns false if the request url does not start with https" do
      request.url = "http://example.com"
      expect(request).not_to be_ssl
    end

    it "returns true if the request url starts with https" do
      request.url = "https://example.com"
      expect(request).to be_ssl
    end

    context "with an explicit value" do
      it "returns the value" do
        request.ssl = true
        expect(request).to be_ssl
      end
    end
  end

  describe "#headers" do
    it "lets you specify a Hash of HTTP request headers" do
      request.headers = { "Accept-Encoding" => "gzip" }
      expect(request.headers).to eq({ "Accept-Encoding" => "gzip" })
    end

    it "defaults to return an empty Hash" do
      expect(request.headers).to eq({})
    end
  end

  describe "#gzip" do
    it "adds the proper 'Accept-Encoding' header" do
      request.gzip
      expect(request.headers["Accept-Encoding"]).to eq("gzip,deflate")
    end
  end

  describe "#set_cookies" do
    it "sets the cookie header for the next request" do
      request.set_cookies response_with_cookie("some-cookie=choc-chip")
      expect(request.headers["Cookie"]).to eq("some-cookie=choc-chip")
    end

    it "sets additional cookies from subsequent requests" do
      request.set_cookies response_with_cookie("some-cookie=choc-chip")
      request.set_cookies response_with_cookie("second-cookie=oatmeal")

      expect(request.headers["Cookie"]).to include("some-cookie=choc-chip", "second-cookie=oatmeal")
    end

    it "accepts an Array of cookies" do
      cookies = [
        new_cookie("some-cookie=choc-chip"),
        new_cookie("second-cookie=oatmeal")
      ]

      request.set_cookies(cookies)

      expect(request.headers["Cookie"]).to include("some-cookie=choc-chip", "second-cookie=oatmeal")
    end

    it "doesn't do anything if the response contains no cookies" do
      request.set_cookies HTTPI::Response.new(200, {}, "")
      expect(request.headers).not_to include("Cookie")
    end

    def new_cookie(cookie_string)
      HTTPI::Cookie.new(cookie_string)
    end

    def response_with_cookie(cookie)
      HTTPI::Response.new(200, { "Set-Cookie" => "#{cookie}; Path=/; HttpOnly" }, "")
    end
  end

  describe "#body" do
    context "with query parameter as String" do
      it "lets you specify the HTTP request body using a String" do
        request.body = "<some>xml</some>"
        expect(request.body).to eq("<some>xml</some>")
      end
    end
    context "with flat query builder" do
      it "lets you specify the HTTP request body using a Hash" do
        request.body = {:foo => :bar, :baz => :foo}
        expect(request.body.split("&")).to match_array(["foo=bar", "baz=foo"])
      end
    end
    context "with query parameter as Hash" do
      context "with flat query builder" do
        it "request body using a Hash" do
          request.body = {:foo => :bar, :baz => :foo}
          expect(request.body.split("&")).to match_array(["foo=bar", "baz=foo"])
        end
        it "request body using a Hash with Array" do
          request.body = {:foo => :bar, :baz => [:foo, :tst]}
          expect(request.body.split("&")).to match_array(["foo=bar", "baz=foo", "baz=tst"])
        end
      end
      context "with nested query builder" do
        before { HTTPI.query_builder = :nested }
        after  { HTTPI.query_builder = :flat }
        it "request body using a Hash" do
          request.body = {:foo => :bar, :baz => :foo}
          expect(request.body.split("&")).to match_array(["foo=bar", "baz=foo"])
        end
        it "request body using a Hash with Array" do
          request.body = {:foo => :bar, :baz => [:foo, :tst]}
          expect(request.body.split("&")).to match_array(["foo=bar", "baz[]=foo", "baz[]=tst"])
        end
      end
    end
  end

  describe "#open_timeout" do
    it "lets you specify the open timeout" do
      request.open_timeout = 30
      expect(request.open_timeout).to eq(30)
    end
  end

  describe "#read_timeout" do
    it "lets you specify the read timeout" do
      request.read_timeout = 45
      expect(request.read_timeout).to eq(45)
    end
  end

  describe "#auth" do
    it "returns the authentication object" do
      expect(request.auth).to be_an(HTTPI::Auth::Config)
    end

    it "memoizes the authentication object" do
      expect(request.auth).to equal(request.auth)
    end
  end

  describe "#auth?" do
    it "returns true when auth credentials are specified" do
      request.auth.basic "username", "password"
      expect(request.auth?).to be_truthy
    end

    it "returns false otherwise" do
      expect(request.auth?).to be_falsey
    end
  end

  describe '#follow_redirect?' do
    it 'returns true when follow_redirect is set to true' do
      request.follow_redirect = true
      expect(request.follow_redirect?).to be_truthy
    end

    it 'returns false by default' do
      expect(request.follow_redirect?).to be_falsey
    end
  end

end
