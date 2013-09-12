require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/admin/list_hosts' do

    def create_request(session_data = new_session_data)
      klass.new(session_data)
    end


    def new_session_data
      service = Aviator::Service.new(
        provider: Environment.openstack_admin[:provider],
        service:  Environment.openstack_admin[:auth_service][:name]
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
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'admin', 'list_hosts.rb')
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
      session_data = new_session_data

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
      session_data = new_session_data
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'compute' }
      url          = "#{ service_spec[:endpoints][0][:adminURL] }/os-hosts"
      request      = klass.new(session_data)

      request.url.must_equal url
    end


    validate_response 'no parameters are provided' do
      service = Aviator::Service.new(
        provider: 'openstack',
        service:  'compute',
        default_session_data: new_session_data
      )

      response = service.request :list_hosts

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:hosts].length.wont_equal 0
      response.headers.wont_be_nil
    end


    validate_response 'valid zone parameter is provided' do
      service = Aviator::Service.new(
        provider: 'openstack',
        service:  'compute',
        default_session_data: new_session_data
      )

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
      service = Aviator::Service.new(
        provider: 'openstack',
        service:  'compute',
        default_session_data: new_session_data
      )

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

