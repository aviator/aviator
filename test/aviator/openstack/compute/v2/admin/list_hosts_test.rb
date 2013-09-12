require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/admin/list_hosts' do

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
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'admin', 'list_hosts.rb')
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


    validate_attr :optional_params do
      klass.optional_params.must_equal [:service, :zone]
    end


    validate_attr :url do
      session_data = get_session_data
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'compute' }
      url          = "#{ service_spec[:endpoints][0][:adminURL] }/os-hosts"
      request      = klass.new(session_data)

      request.url.must_equal url
    end


    validate_response 'no parameters are provided' do
      service = session.compute_service

      response = service.request :list_hosts

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:hosts].length.wont_equal 0
      response.headers.wont_be_nil
    end


    validate_response 'valid zone parameter is provided' do
      service = session.compute_service

      response = service.request :list_hosts do |params|
        params[:zone] = 'nova'
      end

      response.status.must_equal 200
      response.headers.wont_be_nil
      response.body.wont_be_nil
      response.body[:hosts].length.wont_equal 0

      response.body[:hosts].each do |host|
        host[:zone].must_equal 'nova'
      end
    end


    validate_response 'invalid zone parameter is provided' do
      service = session.compute_service

      response = service.request :list_hosts do |params|
        params[:zone] = 'nonexistentfalsezone'
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:hosts].length.must_equal 0
      response.headers.wont_be_nil
    end

  end

end

