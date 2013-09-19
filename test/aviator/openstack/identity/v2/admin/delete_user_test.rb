require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/identity/v2/admin/delete_user' do

    def create_request(session_data = get_session_data)
      klass.new(session_data) do |p|
        p[:id] = 'it does not matter for this usage'
      end
    end


    def get_session_data
      session.send :auth_info
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'identity', 'v2', 'admin', 'delete_user.rb')
    end


    def session
      unless @session
        @session = Aviator::Session.new(
                     config_file: Environment.path,
                     environment: 'openstack_admin'
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
      klass.endpoint_type.must_equal :admin
    end


    validate_attr :headers do
      session_data = get_session_data

      headers = { 'X-Auth-Token' => session_data[:access][:token][:id] }

      request = create_request(session_data)

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :delete
    end


    validate_attr :required_params do
      klass.required_params.must_equal [:id]
    end


    validate_attr :url do
      session_data = get_session_data
      service_spec = session_data[:access][:serviceCatalog].find { |s| s[:type] == 'identity' }
      user_id    = 'it does not matter for this test'
      url          = "#{ service_spec[:endpoints][0][:adminURL] }/users/#{ user_id }"

      request = klass.new(session_data) do |p|
        p[:id] = user_id
      end

      request.url.must_equal url
    end


    validate_response 'valid params are provided' do
      # must be hardcoded so as not to inadvertently delete random user
      # in case the corresponding cassette is deleted
      user_id = 'cf086a74f0854398a2a8f6bbee2029e8'

      response = session.identity_service.request :delete_user do |params|
        params[:id] = user_id
      end

      response.status.must_equal 204
      response.body.must_be_empty
      response.headers.wont_be_nil
    end


    validate_response 'invalid params are provided' do
      user_id = 'bogususerid'

      response = session.identity_service.request :delete_user do |params|
        params[:id] = user_id
      end

      response.status.must_equal 404
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end

  end

end
