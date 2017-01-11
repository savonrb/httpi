require "httpi/adapter/base"
require "httpi/response"

module HTTPI
  module Adapter

    # = HTTPI::Adapter::HTTP
    #
    # Adapter for the http.rb client.
    # https://github.com/httprb/http.rb
    class HTTP < Base

      register :http, :deps => %w(http)

      def initialize(request)
        if request.auth.digest?
          raise NotSupportedError, "http.rb does not support HTTP digest authentication"
        end
        if request.auth.ntlm?
          raise NotSupportedError, "http.rb does not support NTLM digest authentication"
        end

        @request = request
        @client = create_client
      end

      attr_reader :client

      # Executes arbitrary HTTP requests.
      # @see HTTPI.request
      def request(method)
        unless ::HTTP::Request::METHODS.include? method
          raise NotSupportedError, "http.rb does not support custom HTTP methods"
        end
        response = begin
          @client.send(method, @request.url, :body => @request.body)
        rescue OpenSSL::SSL::SSLError
          raise SSLError
        end

        Response.new(response.code, response.headers.to_h, response.body.to_s)
      end

      private

      def create_client
        if @request.ssl?
          context = OpenSSL::SSL::SSLContext.new

          context.options = OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:options]

          if @request.auth.ssl.ca_cert_file != nil
            context.ca_file = @request.auth.ssl.ca_cert_file
          else
            context.cert_store = OpenSSL::SSL::SSLContext::DEFAULT_CERT_STORE
          end

          context.cert        = @request.auth.ssl.cert
          context.key         = @request.auth.ssl.cert_key
          context.ssl_version = @request.auth.ssl.ssl_version if @request.auth.ssl.ssl_version != nil
          context.verify_mode = @request.auth.ssl.openssl_verify_mode

          client = ::HTTP::Client.new(:ssl_context => context)
        else
          client = ::HTTP
        end

        if @request.auth.basic?
          client = client.basic_auth(:user => @request.auth.credentials[0], :pass => @request.auth.credentials[1])
        end

        if @request.proxy != nil
          client = client.via(@request.proxy.host, @request.proxy.port, @request.proxy.user, @request.proxy.password)
        end

        client.headers(@request.headers)
      end
    end
  end
end
