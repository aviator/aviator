require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/public/list_keypairs' do

    def create_request(session_data = get_session_data, &block)
      klass.new(session_data, &block)
    end

    def get_session_data
      session.send :auth_info
    end

    def helper
      Aviator::Test::RequestHelper
    end

    def klass
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'public', 'list_keypairs.rb')
    end

    def session
      unless @session
        @session = Aviator::Session.new(
                     config_file: Environment.path,
                     environment: 'openstack_member'
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
      klass.body?.must_equal false
      create_request.body?.must_equal false
    end

    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :public
    end

    validate_attr :headers do
      session_data = get_session_data

      headers = { 'X-Auth-Token' => session_data[:access][:token][:id] }

      request = create_request(session_data)

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
      service_spec = get_session_data[:access][:serviceCatalog].find{ |s| s[:type] == 'compute' }
      url          = "#{ service_spec[:endpoints][0][:publicURL] }/os-keypairs"

      request = create_request

      request.url.must_equal url
    end

    validate_response 'no parameters are provided' do
      service  = session.compute_service

      response = service.request :list_keypairs
      response.status.must_equal 200
      response.body.wont_be_nil

      # create keypair
      service.request :create_or_import_keypair do |params|
        params[:name] = "keypair name"
      end

      response = service.request :list_keypairs
      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:keypairs].length.wont_equal 0
      response.headers.wont_be_nil
    end
  end
end
