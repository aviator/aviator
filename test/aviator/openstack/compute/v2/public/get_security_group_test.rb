require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/public/get_security_group' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |params|
                  params[:security_group_id] = 0
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
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'public', 'get_security_group.rb')
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
                     environment: 'openstack_member'
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
      klass.endpoint_type.must_equal :public
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
      klass.required_params.must_equal [:security_group_id]
    end


    validate_attr :url do
      session_data = get_session_data
      service_spec = session_data[:access][:serviceCatalog].find { |s| s[:type] == 'compute' }
      sec_id       = 'secID'
      url          = "#{ service_spec[:endpoints][0][:publicURL] }/os-security-groups/#{ sec_id }"

      request = klass.new(session_data) do |p|
        p[:security_group_id] = sec_id
      end

      request.url.must_equal url
    end


    validate_response 'valid ID params is provided' do
      service = session.compute_service

      list_response = service.request :list_security_groups
      sec_id = list_response.body[:security_groups].first[:id]

      response = service.request :get_security_group do |params|
        params[:security_group_id] = sec_id
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:security_group].wont_be_nil
      response.body[:security_group][:id].must_equal sec_id
      response.headers.wont_be_nil
    end


    validate_response 'invalid ID params is provided' do
      service = session.compute_service

      response = service.request :get_security_group do |params|
        params[:security_group_id] = 'invalidStringID'
      end

      response.status.must_equal 400
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


  end

end
