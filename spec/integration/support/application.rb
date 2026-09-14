require "rack"
require "rack/builder"
require "integration/support/digest_auth"

class IntegrationServer
  def self.respond_with(body)
    [200, {"Content-Type" => "text/plain", "Content-Length" => body.size.to_s}, [body]]
  end

  Application = Rack::Builder.new do
    map "/" do
      run lambda { |env|
        IntegrationServer.respond_with env["REQUEST_METHOD"].downcase
      }
    end

    map "/timeout" do
      run lambda { |env|
        sleep 2
        IntegrationServer.respond_with "done"
      }
    end

    map "/x-header" do
      run lambda { |env|
        IntegrationServer.respond_with env["HTTP_X_HEADER"]
      }
    end

    map "/cookies" do
      run lambda { |env|
        status, headers, body = IntegrationServer.respond_with("Many Cookies")
        response = Rack::Response.new(body, status, headers)

        response.set_cookie("cookie1", {value: "chip1", path: "/"})
        response.set_cookie("cookie2", {value: "chip2", path: "/"})
        response.finish
      }
    end

    map "/basic-auth" do
      use Rack::Auth::Basic, "basic-realm" do |username, password|
        username == "admin" && password == "secret"
      end

      run lambda { |env|
        IntegrationServer.respond_with "basic-auth"
      }
    end

    map "/ntlm-auth" do
      run lambda { |env|
        # head request 1: challenge & response (from actual server)
        resp = if env["HTTP_AUTHORIZATION"] =~ /(NTLM|Negotiate) TlRMTVNTUAABAAAAB4IIAA/
          [401, {
            "Content-Type" => "text/html; charset=us-ascii",
            "Server" => "Microsoft-HTTPAPI/2.0",
            "WWW-Authenticate" => "#{$1} TlRMTVNTUAACAAAAEAAQADgAAAAFgooCj/AvDazHhQsAAAAAAAAAAGAAYABIAAAABgLwIwAAAA9OAFQATABNAFQARQBTAFQAAgAQAE4AVABMAE0AVABFAFMAVAABABAATgBUAEwATQBUAEUAUwBUAAQAEABuAHQAbABtAHQAZQBzAHQAAwAQAG4AdABsAG0AdABlAHMAdAAHAAgAfzQp037nzQEAAAAA",
            "Date" => "Mon, 31 Dec 2012 17:46:55 GMT"
          }, []]
        elsif /(NTLM|Negotiate) (.+)/.match?(env["HTTP_AUTHORIZATION"])
          # request 2: serve content
          IntegrationServer.respond_with "ntlm-auth"
        else
          [401, {
            "Content-Type" => "text/html; charset=us-ascii",
            "WWW-Authenticate" => "NTLM\nNegotiate",
            "Server" => "Microsoft-HTTPAPI/2.0",
            "Date" => "Mon, 31 Dec 2012 17:46:55 GMT"
          }, []]
        end
        resp
      }
    end

    map "/digest-auth" do
      unprotected_app = lambda { |env|
        IntegrationServer.respond_with "digest-auth"
      }

      realm = "digest-realm"
      app = IntegrationServer::DigestAuth.new(unprotected_app) do |username|
        (username == "admin" ? Digest::MD5.hexdigest("admin:#{realm}:secret") : nil)
      end
      app.realm = realm
      app.opaque = "this-should-be-secret"
      app.passwords_hashed = true

      run app
    end
  end
end
