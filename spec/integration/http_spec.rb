require "spec_helper"
require "integration/server"

describe HTTPI do

  before :all do
    WebMock.allow_net_connect!

    @username = "admin"
    @password = "secret"
    @content_type = "text/plain"

    @server = IntegrationServer.run(:port => 4000)
  end

  after :all do
    @server.stop
  end

  shared_examples_for "an HTTP client" do
    it "and send HTTP headers" do
      request = HTTPI::Request.new("http://localhost:4000/x-header")
      request.headers["X-Header"] = "HTTPI"

      response = HTTPI.get(request, adapter)
      response.body.should include("HTTPI")
    end

    it "and execute an HTTP GET request" do
      response = HTTPI.get("http://localhost:4000", adapter)
      response.body.should eq("get")
      response.headers["Content-Type"].should include(@content_type)
    end

    it "and execute an HTTP POST request" do
      response = HTTPI.post("http://localhost:4000", "<some>xml</some>", adapter)
      response.body.should eq("post")
      response.headers["Content-Type"].should include(@content_type)
    end

    it "and execute an HTTP HEAD request" do
      response = HTTPI.head("http://localhost:4000", adapter)
      response.code.should == 200
      response.headers["Content-Type"].should include(@content_type)
    end

    it "and execute an HTTP PUT request" do
      response = HTTPI.put("http://localhost:4000", "<some>xml</some>", adapter)
      response.body.should eq("put")
      response.headers["Content-Type"].should include(@content_type)
    end

    it "and execute an HTTP DELETE request" do
      response = HTTPI.delete("http://localhost:4000", adapter)
      response.body.should eq("delete")
      response.headers["Content-Type"].should include(@content_type)
    end
  end

  shared_examples_for "it works with HTTP basic auth" do
    it "and access a secured page" do
      request = HTTPI::Request.new("http://localhost:4000/basic-auth")
      request.auth.basic(@username, @password)

      response = HTTPI.get(request, adapter)
      response.body.should eq("basic-auth")
    end
  end

  shared_examples_for "it works with HTTP digest auth" do
    it "and access a secured page" do
      request = HTTPI::Request.new("http://localhost:4000/digest-auth")
      request.auth.digest("admin", "secret")

      response = HTTPI.get(request, adapter)
      response.body.should eq("digest-auth")
    end
  end

  all_adapters = HTTPI::Adapter::ADAPTERS.keys

  all_adapters.each do |adapter|

    around :each do |example|
      # Only wrap the example for the :em_http adapter
      if adapter == :em_http && RUBY_VERSION >= "1.9.0"
        if EM.respond_to?(:synchrony)
          EM.synchrony do
            example.run
            EM.stop
          end
        end
      else
        example.run
      end
    end

    unless (adapter == :curb && RUBY_PLATFORM =~ /java/) || (adapter == :em_http && RUBY_VERSION =~ /1\.8/)
      context "using :#{adapter}" do
        let(:adapter) { adapter }
        it_should_behave_like "an HTTP client"
        it_should_behave_like "it works with HTTP basic auth"
      end
    end
  end

  all_adapters_without_net_http = HTTPI::Adapter::ADAPTERS.keys - [:net_http]

  all_adapters_without_net_http.each do |adapter|
    unless (adapter == :curb && RUBY_PLATFORM =~ /java/) || adapter == :em_http
      context "using :#{adapter}" do
        let(:adapter) { adapter }
        it_should_behave_like "it works with HTTP digest auth"
      end
    end
  end

end
