require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/admin/create_flavor' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |params|
                  params[:tenant_id] = '123123213'
                  params[:id] = 'auto'
                  params[:vcpus] = '1'
                  params[:ram] = '526'
                  params[:disk] = '1'
                  params[:name] = 'validname'
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
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'admin', 'create_flavor.rb')
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
      headers = { 'X-Auth-Token' => get_session_data.token }

      request = create_request

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :post
    end

    validate_attr :url do
      session_data = helper.admin_session_data
      service_spec = get_session_data[:catalog].find{ |s| s[:type] == 'compute' }
      url          = "#{ service_spec[:endpoints].find{|e| e[:interface] == 'admin'}[:url] }/flavors"

      request = create_request
      request.url.must_equal url
    end


    validate_response 'valid parameters are provided' do
      tenant    = session.identity_service.request(:list_tenants).body[:tenants].first
      tenant_id = tenant[:id]

      response = session.compute_service.request :create_flavor do |params|
        params[:tenant_id] = tenant_id
        params[:disk] = '1'
        params[:ram] = '526'
        params[:vcpus] = '1'
        params[:name] = 'testflavor'
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:flavor].wont_be_nil
      response.headers.wont_be_nil
    end

    validate_response 'valid parameters are provided except for tenant_id' do

      response = session.compute_service.request :create_flavor do |params|
        params[:tenant_id] = ''
        params[:disk] = '1'
        params[:ram] = '526'
        params[:vcpus] = '1'
        params[:name] = 'testflavor'
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:flavor].wont_be_nil
      response.headers.wont_be_nil
    end


    validate_response 'invalid parameters are provided' do
      response = session.compute_service.request :create_flavor do |params|
        params[:id] = 'auto'
        params[:tenant_id] = '123123213'
        params[:disk] = '1'
        params[:ram] = '526'
        params[:name] = 123123213
        params[:vcpus] = '1'
      end

      response.status.must_equal 400
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


  end

end
