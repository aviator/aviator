require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/identity/v2/admin/update_user' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda { |p| p[:id] = 0 }
      klass.new(session_data, &block)
    end


    def get_session_data
      session.send :auth_info
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'identity', 'v2', 'admin', 'update_user.rb')
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
      request = create_request

      klass.body?.must_equal true
      request.body?.must_equal true
      request.body.wont_be_nil
    end


    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :admin
    end


    validate_attr :headers do
      headers = { 'X-Auth-Token' => get_session_data[:access][:token][:id] }

      request = create_request

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :put
    end


    validate_attr :required_params do
      klass.required_params.must_equal [:id]
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal [
        :name,
        :password,
        :email,
        :enabled,
        :tenantId
      ]
    end


    validate_attr :url do
      user_id = 'thisdoesntneedtobevalidinthistest'

      service_spec = get_session_data[:access][:serviceCatalog].find { |s| s[:type] == 'identity' }
      url          = "#{ service_spec[:endpoints][0][:adminURL] }/users/#{ user_id }"

      request = create_request do |params|
        params[:id] = user_id
      end

      request.url.must_equal url
    end


    validate_response 'valid user id is provided' do
      # must be hardcoded so as not to inadvertently alter random resources
      # in case the corresponding cassette is deleted
      user_id  = 'cf086a74f0854398a2a8f6bbee2029e8'
      new_name = 'updated_name'

      response = session.identity_service.request :update_user do |params|
        params[:id]   = user_id
        params[:name] = new_name
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:user].wont_be_nil
      response.body[:user][:name].must_equal new_name
      response.headers.wont_be_nil
    end


    validate_response 'invalid user id is provided' do
      user_id = 'abogususeridthatdoesnotexist'

      response = session.identity_service.request :update_user do |params|
        params[:id]   = user_id
        params[:name] = 'it does not matter'
      end

      response.status.must_equal 404
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


  end

end
