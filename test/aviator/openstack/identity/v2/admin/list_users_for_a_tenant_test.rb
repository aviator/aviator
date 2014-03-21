require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/identity/v2/admin/list_users_for_a_tenant' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |params|
                  params[:tenant_id] = 0
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
      @klass ||= helper.load_request('openstack', 'identity', 'v2', 'admin', 'list_users_for_a_tenant.rb')
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
      create_request.http_method.must_equal :get
    end


    validate_attr :url do
      tenant_id = 'sample_tenant_id'
      session_data = get_session_data
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'identity' }
      url          = "#{ service_spec[:endpoints][0][:adminURL] }/tenants/#{ tenant_id }/users"
      request = create_request do |p|
        p[:tenant_id] = tenant_id
      end

      request.url.must_equal url
    end


    validate_response 'valid tenant id is provided' do
      # must be hardcoded so as not to inadvertently alter random resources
      # in case the corresponding cassette is deleted
      tenant_id = '5797bb4fb10c416bb2fb6534d12bd34b'

      response = session.identity_service.request :list_users_for_a_tenant do |params|
        params[:tenant_id] = tenant_id
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:users].wont_be_nil
      response.headers.wont_be_nil
    end


    validate_response 'invalid tenant id is provided' do
      # must be hardcoded so as not to inadvertently alter random resources
      # in case the corresponding cassette is deleted
      tenant_id = 'abogustenantidthatdoesnotexist'

      response = session.identity_service.request :list_users_for_a_tenant do |params|
        params[:tenant_id] = tenant_id
      end

      response.status.must_equal 404
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


  end

end
