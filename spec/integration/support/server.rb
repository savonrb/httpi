require "puma"
require "puma/minissl"

require "integration/support/application"

class IntegrationServer

  def self.run(options = {})
    server = new(options)
    server.run
    server
  end

  def self.ssl_ca_file;   File.expand_path("../fixtures/ca_all.pem", __FILE__)  end
  def self.ssl_key_file;  File.expand_path("../fixtures/server.key", __FILE__)  end
  def self.ssl_cert_file; File.expand_path("../fixtures/server.cert", __FILE__) end

  def initialize(options = {})
    @app  = Application
    @host = options.fetch(:host, "localhost")
    @port = options.fetch(:port, 17172)
    @ssl  = options.fetch(:ssl, false)

    @server = Puma::Server.new(app, events)

    if ssl?
      add_ssl_listener
    else
      add_tcp_listener
    end
  end

  attr_reader :app, :host, :port, :server

  def url
    protocol = ssl? ? "https" : "http"
    "#{protocol}://#{host}:#{port}/"
  end

  def ssl?
    @ssl
  end

  def run
    server.run
  end

  def stop
    server.stop(true)
  end

  private

  def events
    Puma::Events.new($stdout, $stderr)
  end

  def add_tcp_listener
    server.add_tcp_listener(host, port)
  rescue Errno::EADDRINUSE
    raise "Panther is already running at #{url}"
  end

  def add_ssl_listener
    server.add_ssl_listener(host, port, ssl_context)
  end

  def ssl_context
    context = Puma::MiniSSL::Context.new

    context.key         = IntegrationServer.ssl_key_file
    context.cert        = IntegrationServer.ssl_cert_file
    context.verify_mode = Puma::MiniSSL::VERIFY_PEER

    context
  end

end
