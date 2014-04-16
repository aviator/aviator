require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/admin/get_quotas' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |params|
                  params[:tenant_id] = 'theTenant'
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
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'admin', 'get_quotas.rb')
    end


    def tenant_id
      return @tenant_id unless @tenant_id.nil?

      response   = session.identity_service.request(:list_tenants)
      @tenant_id = response.body[:tenants].last[:id]
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

      create_request(session_data).headers.must_equal headers
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :get
    end


    validate_attr :required_params do
      klass.required_params.must_equal [:tenant_id]
    end


    validate_attr :url do
      session_data = get_session_data
      service_spec = session_data[:access][:serviceCatalog].find { |s| s[:type] == 'compute' }
      url          = "#{ service_spec[:endpoints][0][:adminURL] }/os-quota-sets/#{ tenant_id }"

      request = klass.new(session_data) do |p|
        p[:tenant_id] = tenant_id
      end

      request.url.must_equal url
    end


    validate_response 'a valid param is provided' do
      response = session.compute_service.request :get_quotas do |params|
        params[:tenant_id] = tenant_id
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:quota_set].wont_be_nil
      response.headers.wont_be_nil
    end


    validate_response 'non existent tenant is provided' do
      response = session.compute_service.request :get_quotas do |params|
        params[:tenant_id] = 'nonExistenTenant'
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:quota_set].wont_be_nil
      response.headers.wont_be_nil
    end


  end

end
