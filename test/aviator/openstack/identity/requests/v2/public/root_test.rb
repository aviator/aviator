require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/identity/requests/v2/public/root' do

    def create_request(session_data = get_session_data)
      klass.new(session_data)
    end


    def get_session_data
      session.send :auth_response
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'identity', 'v2', 'public', 'root.rb')
    end


    def session
      unless @session
        @session = Aviator::Session.new(
                     :config_file => Environment.path,
                     :environment => 'openstack_member'
                   )
        @session.authenticate
      end

      @session
    end


    validate_attr :anonymous? do
      klass.anonymous?.must_equal false
    end


    validate_attr :api_version do
      klass.api_version.must_equal :v2
    end


    validate_attr :body do
      request = create_request

      klass.body?.must_equal false
      request.body?.must_equal false
    end


    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :public
    end


    validate_attr :headers do
      headers = { 'X-Auth-Token' => get_session_data[:body][:access][:token][:id] }

      request = create_request

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :get
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal []
    end


    validate_attr :required_params do
      klass.required_params.must_equal []
    end


    validate_attr :url do
      service_spec = get_session_data[:body][:access][:serviceCatalog].find{|s| s[:type] == 'identity' }
      uri          = URI(service_spec[:endpoints][0][:publicURL])
      url          = "#{ uri.scheme }://#{ uri.host }:#{ uri.port.to_s }/v2.0/"

      create_request.url.must_equal url
    end



    validate_response 'no parameters are provided' do
      response = session.identity_service.request :root

      response.status.must_equal 200
      response.body.wont_be_nil
    end

  end

end
