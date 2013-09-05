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
      
      bootstrap = RequestHelper.admin_bootstrap_session_data
      
      response = service.request :create_token, session_data: bootstrap do |params|
        auth_credentials = Environment.openstack_admin[:auth_credentials]
        auth_credentials.each { |key, value| params[key] = auth_credentials[key] }
      end
      
      response.body
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'identity', 'v2', 'admin', 'create_tenant.rb')
    end


    validate_attr :api_version do
      klass.api_version.must_equal :v2
    end


    validate_attr :anonymous? do
      klass.anonymous?.must_equal false
    end


    validate_attr :body do
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


    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :admin
    end


    validate_attr :headers do
      headers = { 'X-Auth-Token' => helper.admin_session_data[:access][:token][:id] }

      request = create_request

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :post
    end


    validate_attr :required_params do
      klass.required_params.must_equal [:name, :description, :enabled]
    end


    validate_attr :url do
      session_data = helper.admin_session_data
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'identity' }
      url = "#{ service_spec[:endpoints][0][:adminURL] }/tenants"

      request = create_request

      request.url.must_equal url
    end


    validate_response 'params are invalid' do
      service = Aviator::Service.new(
        provider: 'openstack',
        service:  'identity',
        default_session_data: new_session_data
      )
      
      response = service.request :create_tenant do |params|
        params[:name]        = ""
        params[:description] = ""
        params[:enabled]     = true
      end
      
      response.status.must_equal 400
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end
    
    
    validate_response 'params are valid' do
      service = Aviator::Service.new(
        provider: 'openstack',
        service:  'identity',
        default_session_data: new_session_data
      )
      
      response = service.request :create_tenant do |params|
        params[:name]        = "Aviator Project"
        params[:description] = 'My Project'
        params[:enabled]     = true
      end
      
      response.status.must_equal 200
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


  end

end