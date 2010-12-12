require "spec_helper"
require "mock_server"

IntegrationServer = Rack::Builder.new do
  map "/" do
    run lambda {|env|
      case env["REQUEST_METHOD"]
      when "HEAD" then
        [200, {"Content-Type" => "text/plain", "Content-Length" => "5"}, []]
      when "GET", "POST" then
        [200, {"Content-Type" => "text/plain", "Content-Length" => "5"}, ["Hello"]]
      when "PUT", "DELETE"
        body = "#{env["REQUEST_METHOD"]} is not allowed"
        [200, {"Content-Type" => "text/plain", "Content-Length" => body.size.to_s}, [body]]
      end
    }
  end

  map "/x-header" do
    run lambda {|env|
      body = "X-Header is #{env["HTTP_X_HEADER"]}"
      [200, {"Content-Type" => "text/plain", "Content-Length" => body.size.to_s}, [body]]
    }
  end

  map "/auth" do
    map "/basic" do
      run Rack::Auth::Basic do |user, password|
        user == "admin" && password == "secret"
      end
    end

    map "/digest" do
      run Rack::Auth::Digest::MD5 do |username|
        {"admin" => "pwd"}[username]
      end
    end
  end
end
