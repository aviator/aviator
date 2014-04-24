require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/admin/get_host_details' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |params|
                  params[:host_name] = 'doesnotmatterinthiscase'
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
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'admin', 'get_host_details.rb')
    end


    def host_name
      return @host_name unless @host_name.nil?

      response   = session.compute_service.request(:list_hosts)
      @host_name = response.body[:hosts].last[:host_name]
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

      headers = { 'X-Auth-Token' => session_data.token }

      create_request(session_data).headers.must_equal headers
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :get
    end


    validate_attr :required_params do
      klass.required_params.must_equal [:host_name]
    end


    validate_attr :url do
      session_data = get_session_data
      service_spec = session_data[:catalog].find { |s| s[:type] == 'compute' }
      url          = "#{ service_spec[:endpoints][0][:adminURL] }/os-hosts/#{ host_name }"

      request = klass.new(session_data) do |p|
        p[:host_name] = host_name
      end

      request.url.must_equal url
    end


    validate_response 'valid params are provided' do
      service = session.compute_service

      response = service.request :get_host_details do |params|
        params[:host_name] = host_name
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


    validate_response 'invalid params are provided' do
      service = session.compute_service

      response = service.request :get_host_details do |params|
        params[:host_name] = 'nonexistenthost'
      end

      response.status.must_equal 404
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


  end

end
