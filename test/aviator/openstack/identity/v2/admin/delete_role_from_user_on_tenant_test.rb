require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/identity/v2/admin/delete_role_from_user_on_tenant' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |params|
                  params[:tenant_id] = 0
                  params[:role_id]   = 0
                  params[:user_id]   = 0
                end

      klass.new(session_data, &block)
    end


    def get_session_data
      session.send :auth_info
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'identity', 'v2', 'admin', 'delete_role_from_user_on_tenant.rb')
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


    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :admin
    end


    validate_attr :headers do
      headers = { 'X-Auth-Token' => get_session_data[:access][:token][:id] }

      request = create_request

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :delete
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal []
    end


    validate_attr :required_params do
      klass.required_params.must_equal [
        :tenant_id,
        :user_id,
        :role_id
      ]
    end


    validate_attr :url do
      tenant_id = 'sample_tenant_id'
      user_id   = 'sample_user_id'
      role_id   = 'sample_role_id'

      service_spec = get_session_data[:access][:serviceCatalog].find { |s| s[:type] == 'identity' }
      url          = "#{ service_spec[:endpoints][0][:adminURL] }/tenants/#{ tenant_id }"
      url         += "/users/#{ user_id }"
      url         += "/roles/OS-KSADM/#{ role_id }"

      request = create_request do |p|
        p[:tenant_id] = tenant_id
        p[:user_id]   = user_id
        p[:role_id]   = role_id
      end

      request.url.must_equal url
    end


    validate_response 'valid ids are provided' do
      # must be hardcoded so as not to inadvertently alter random resources
      # in case the corresponding cassette is deleted
      tenant_id = '3c7492bd83ed43bcb4953c621cfe21be'
      user_id   = 'd5abadb115c2415fa11d5e39bdecb2e6'
      role_id   = '998b01cf9f31410b97412d115eed9c3a'

      response = session.identity_service.request :delete_role_from_user_on_tenant do |params|
        params[:tenant_id] = tenant_id
        params[:user_id]   = user_id
        params[:role_id]   = role_id
      end

      response.status.must_equal 204
      response.body.must_be_empty
      response.headers.wont_be_nil
    end


    validate_response 'invalid tenant id is provided' do
      # must be hardcoded so as not to inadvertently alter random resources
      # in case the corresponding cassette is deleted
      user_id   = '02abfc09286743f298dde7aa2a4f6850'
      role_id   = 'd4aeb8a6093243fda5bf938f2c0bccfd'

      tenant_id = 'abogustenantidthatdoesnotexist'

      response = session.identity_service.request :delete_role_from_user_on_tenant do |params|
        params[:tenant_id] = tenant_id
        params[:user_id]   = user_id
        params[:role_id]   = role_id
      end

      response.status.must_equal 404
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


    validate_response 'invalid user id is provided' do
      # must be hardcoded so as not to inadvertently alter random resources
      # in case the corresponding cassette is deleted
      tenant_id = '2f2a15ea1edc40b6a7372076acebb097'
      role_id   = 'd4aeb8a6093243fda5bf938f2c0bccfd'

      user_id   = 'abogususeridthatdoesnotexist'

      response = session.identity_service.request :delete_role_from_user_on_tenant do |params|
        params[:tenant_id] = tenant_id
        params[:user_id]   = user_id
        params[:role_id]   = role_id
      end

      response.status.must_equal 404
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


    validate_response 'invalid role id is provided' do
      # must be hardcoded so as not to inadvertently alter random resources
      # in case the corresponding cassette is deleted
      tenant_id = '2f2a15ea1edc40b6a7372076acebb097'
      user_id   = '02abfc09286743f298dde7aa2a4f6850'

      role_id   = 'abogusroleidthatdoesnotexist'

      response = session.identity_service.request :delete_role_from_user_on_tenant do |params|
        params[:tenant_id] = tenant_id
        params[:user_id]   = user_id
        params[:role_id]   = role_id
      end

      response.status.must_equal 404
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


  end

end
