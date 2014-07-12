require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/identity/requests/v2/admin/get_tenant_by_id' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |params|
                  params[:id] = 'this_doesnt_matter_with_this_test'
                end

      klass.new(session_data, &block)
    end


    def get_session_data
      session.send :auth_response
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'identity', 'v2', 'admin', 'get_tenant_by_id.rb')
    end


    def session
      unless @session
        @session = Aviator::Session.new(
          :config_file => Environment.path,
          :environment => 'openstack_admin'
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

      headers = { 'X-Auth-Token' => session_data[:body][:access][:token][:id] }

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
      klass.required_params.must_equal [:id]
    end


    validate_attr :url do
      session_data = get_session_data
      service_spec = session_data[:body][:access][:serviceCatalog].find{|s| s[:type] == 'identity' }
      tenant_id    = 'itdoesnotmatter'
      url          = "#{ service_spec[:endpoints][0][:adminURL] }/tenants/#{ tenant_id }"

      request = create_request do |p|
        p[:id] = tenant_id
      end

      request.url.must_equal url
    end


    validate_response 'a valid tenant id is provided' do
      service = session.identity_service
      tenant  = session.identity_service.request(:list_tenants).body[:tenants].first

      response = service.request :get_tenant_by_id do |p|
        p[:id] = tenant[:id]
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:tenant][:id].must_equal tenant[:id]
      response.headers.wont_be_nil
    end


  end

end
