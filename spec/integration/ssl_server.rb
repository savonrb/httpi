require "webrick/https"
require "logger"
require "cgi"

# https://github.com/asakusarb/odrk-http-client
class SSLServer < WEBrick::HTTPServer
  DIR = File.dirname(__FILE__)

  def initialize(host, port)
    @logger = Logger.new($stderr)
    @logger.level = Logger::Severity::FATAL

    super(
      :BindAddress          => host,
      :Logger               => logger,
      :Port                 => port,
      :AccessLog            => [],
      :DocumentRoot         => DIR,
      :SSLEnable            => true,
      :SSLCACertificateFile => File.join(DIR, "fixtures", "ca.pem"),
      :SSLCertificate       => cert("server.cert"),
      :SSLPrivateKey        => key("server.key"),
      :SSLVerifyClient      => nil, #OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT|OpenSSL::SSL::VERIFY_PEER,
      :SSLClientCA          => nil,
      :SSLCertName          => nil
    )

    self.mount(
      "/hello",
      WEBrick::HTTPServlet::ProcHandler.new(method("do_hello").to_proc)
    )

    @server_thread = start_server_thread(self)
  end

  def shutdown
    super
    @server_thread.join if defined?(RUBY_ENGINE) && RUBY_ENGINE == "rbx"
  end

  private

  def cert(filename)
    OpenSSL::X509::Certificate.new File.read(File.join(DIR, "fixtures", filename))
  end

  def key(filename)
    OpenSSL::PKey::RSA.new File.read(File.join(DIR, "fixtures", filename))
  end

  def start_server_thread(server)
    t = Thread.new { server.start }

    while server.status != :Running
      Thread.pass
      unless t.alive?
        t.join
        raise
      end
    end

    t
  end

  def do_hello(req, res)
    res["Content-Type"] = "text/plain"
    res.body = "hello ssl"
  end

end
