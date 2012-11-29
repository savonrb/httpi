require "rack/builder"

class IntegrationServer
  Application = Rack::Builder.new do

    map "/" do
      run lambda { |env|
        body = env["REQUEST_METHOD"].downcase
        [200, { "Content-Type" => "text/plain", "Content-Length" => body.size.to_s }, [body]]
      }
    end

    map "/x-header" do
      run lambda { |env|
        body = env["HTTP_X_HEADER"]
        [200, { "Content-Type" => "text/plain", "Content-Length" => body.size.to_s }, [body]]
      }
    end

    map "/basic-auth" do
      use Rack::Auth::Basic, "basic-realm" do |username, password|
        username == "admin" && password == "secret"
      end

      run lambda { |env|
        body = "basic-auth"
        [200, { "Content-Type" => "text/plain", "Content-Length" => body.size.to_s }, [body]]
      }
    end

    map "/digest-auth" do
      unprotected_app = lambda { |env|
        body = "digest-auth"
        [200, { "Content-Type" => "text/plain", "Content-Length" => body.size.to_s }, [body]]
      }

      realm = 'digest-realm'
      app = Rack::Auth::Digest::MD5.new(unprotected_app) do |username|
        username == 'admin' ? Digest::MD5.hexdigest("admin:#{realm}:secret") : nil
      end
      app.realm = realm
      app.opaque = 'this-should-be-secret'
      app.passwords_hashed = true

      run app
    end

  end
end
