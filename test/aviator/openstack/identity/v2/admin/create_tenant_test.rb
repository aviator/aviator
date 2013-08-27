require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/identity/v2/admin/create_tenant' do

    def create_request
      klass.new(helper.admin_session_data) do |params|
        params[:name]        = 'Project'
        params[:description] = 'My Project'
        params[:enabled]     = true
      end
    end


    def new_session_data
      service = Aviator::Service.new(
        provider: 'openstack',
        service:  'identity'
      )
      
      response = service.request :create_token, RequestHelper.admin_bootstrap_session_data do |params|
        auth_credentials = Environment.openstack_admin[:auth_credentials]
        auth_credentials.each { |key, value| params[key] = auth_credentials[key] }
      end
      
      response.body
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      path = helper.request_path('identity', 'v2', 'admin', 'create_tenant.rb')
      klass, request_name = Aviator::Service::RequestBuilder.build(path)
      klass
    end


    it 'has the correct endpoint type' do
      klass.endpoint_type.must_equal :admin
    end


    it 'has the correct api version' do
        klass.api_version.must_equal :v2
    end


    it 'has the correct http method' do
      klass.http_method.must_equal :post
    end


    it 'has the correct list of required parameters' do
      klass.required_params.must_equal [:name, :description, :enabled]
    end


    it 'has the correct url' do
      session_data = helper.admin_session_data
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'identity' }
      url = "#{ service_spec[:endpoints][0][:adminURL] }/tenants"

      request = create_request

      request.url.must_equal url
    end


    it 'has the correct headers' do
      headers = { 'X-Auth-Token' => helper.admin_session_data[:access][:token][:id] }

      request = create_request

      request.headers.must_equal headers
    end


    it 'has the correct body' do
      params = {
        name:        'Project',
        description: 'My Project',
        enabled:      true
      }

      body = {
        tenant: params
      }

      request = klass.new(helper.admin_session_data) do |p|
        params.each do |k,v|
          p[k] = params[k]
        end
      end

      request.body.must_equal body
    end


    it 'leads to a valid response when provided with valid params' do
      service = Aviator::Service.new(
        provider: 'openstack',
        service:  'identity'
      )
      
      response = service.request :create_tenant, new_session_data do |params|
        params[:name]        = "Project 1377582007"
        params[:description] = 'My Project'
        params[:enabled]     = true
      end
      
      response.status.must_equal 200
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


    it 'leads to a valid response when provided with invalid params' do
      service = Aviator::Service.new(
        provider: 'openstack',
        service:  'identity'
      )
      
      response = service.request :create_tenant, new_session_data do |params|
        params[:name]        = ""
        params[:description] = ""
        params[:enabled]     = true
      end
      
      response.status.must_equal 400
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end

  end

end