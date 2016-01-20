require 'base64'
require 'httpi/adapter/base'
require 'httpi/response'

module HTTPI
  module Adapter

    # = HTTPI::Adapter::Rack
    #
    # Adapter for Rack::MockRequest.
    # Due to limitations, not all features are supported.
    # https://github.com/rack/rack/blob/master/lib/rack/mock.rb
    #
    # Usage:
    #
    #   HTTPI::Adapter::Rack.mount 'application', RackApplication
    #   HTTPI.get("http://application/path", :rack)
    class Rack < Base
      register :rack, :deps => %w(rack/mock)

      attr_reader :client

      class << self
        attr_accessor :mounted_apps
      end

      self.mounted_apps = {}

      # Attaches Rack endpoint at specified host.
      # Endpoint will be acessible at {http://host/ http://host/} url.
      def self.mount(host, application)
        self.mounted_apps[host] = application
      end

      # Removes Rack endpoint.
      def self.unmount(host)
        self.mounted_apps.delete(host)
      end

      def initialize(request)
        @app = self.class.mounted_apps[request.url.host]


        if @app.nil?
          message  = "Application '#{request.url.host}' not mounted: ";
          message += "use `HTTPI::Adapter::Rack.mount('#{request.url.host}', RackApplicationClass)`"

          raise message
        end

        @request = request
        @client  = ::Rack::MockRequest.new(@app)
      end

      # Executes arbitrary HTTP requests.
      # You have to mount required Rack application before you can use it.
      #
      # @see .mount
      # @see HTTPI.request
      def request(method)
        unless REQUEST_METHODS.include? method
          raise NotSupportedError, "Rack adapter does not support custom HTTP methods"
        end

        if @request.proxy
          raise NotSupportedError, "Rack adapter does not support proxying"
        end

        if @request.auth.http?
          if @request.auth.basic?
            basic_auth = @request.auth.basic.join(':')
            encoded = Base64.encode64(basic_auth).gsub('\n', '')
            @request.headers['Authorization'] = "Basic #{encoded}"
          else
            raise NotSupportedError, "Rack adapter does not support HTTP #{@request.auth.type} auth"
          end
        end

        if @request.auth.ssl?
          raise NotSupportedError, "Rack adapter does not support SSL client auth"
        end

        if @request.on_body
          raise NotSupportedError, "Rack adapter does not support response streaming"
        end

        env = {}
        @request.headers.each do |header, value|
          env["HTTP_#{header.gsub('-', '_').upcase}"] = value
        end

        response = @client.request(method.to_s.upcase, @request.url.to_s,
              { :fatal => true, :input => @request.body.to_s }.merge(env))

        Response.new(response.status, response.headers, response.body)
      end
    end
  end
end