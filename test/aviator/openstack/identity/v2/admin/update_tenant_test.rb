require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/identity/v2/admin/update_tenant' do

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
      @klass ||= helper.load_request('openstack', 'identity', 'v2', 'admin', 'update_tenant.rb')
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
      request = create_request { |p| p[:id] = 0 }

      klass.body?.must_equal true
      request.body?.must_equal true
      request.body.wont_be_nil
    end


    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :admin
    end


    validate_attr :headers do
      headers = { 'X-Auth-Token' => get_session_data[:access][:token][:id] }

      request = create_request { |p| p[:id] = 0 }

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      create_request { |p| p[:id] = 0 }.http_method.must_equal :put
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal [
        :name,
        :enabled,
        :description
      ]
    end


    validate_attr :required_params do
      klass.required_params.must_equal [:id]
    end


    validate_attr :url do
      # must be hardcoded so as not to inadvertently alter random resources
      # in case the corresponding cassette is deleted
      tenant_id    = '105b09f0b6500d36168480ad84'

      service_spec = get_session_data[:access][:serviceCatalog].find{|s| s[:type] == 'identity' }
      url          = "#{ service_spec[:endpoints][0][:adminURL] }/tenants/#{ tenant_id }"

      request = create_request do |params|
        params[:id] = tenant_id
      end

      request.url.must_equal url
    end


    validate_response 'valid tenant id is provided' do
      tenant    = session.identity_service.request(:list_tenants).body[:tenants].first
      tenant_id = tenant[:id]
      new_name  = 'Updated tenant'

      response = session.identity_service.request :update_tenant do |params|
        params[:id]   = tenant_id
        params[:name] = new_name
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:tenant].wont_be_nil
      response.body[:tenant][:name].must_equal new_name
      response.headers.wont_be_nil
    end


    validate_response 'invalid tenant id is provided' do
      tenant_id = 'abogustenantidthatdoesnotexist'

      response = session.identity_service.request :update_tenant do |params|
        params[:id]   = tenant_id
        params[:name] = 'it does not matter'
      end

      response.status.must_equal 404
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


  end

end
