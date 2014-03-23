require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/public/delete_security_group' do

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
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'public', 'delete_security_group.rb')
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
      request = create_request {|p| p[:id] = 0 }

      klass.body?.must_equal false
      request.body?.must_equal false
    end


    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :public
    end


    validate_attr :headers do
      headers = { 'X-Auth-Token' => get_session_data[:access][:token][:id] }

      request = create_request {|p| p[:id] = 0 }

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      create_request{|p| p[:id] = 0 }.http_method.must_equal :delete
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal []
    end


    validate_attr :required_params do
      klass.required_params.must_equal [:security_group_id]
    end


    validate_attr :url do
      service_spec = get_session_data[:access][:serviceCatalog].find{|s| s[:type] == 'compute' }
      sec_id       = 0
      url          = "#{ service_spec[:endpoints][0][:publicURL] }/os-security-groups/#{ sec_id }"

      request = create_request do |params|
        params[:id] = sec_id
      end

      request.url.must_equal url
    end


    validate_response 'valid security group id is provided' do
      security_group  = session.compute_service.request(:create_security_group) do |params|
                          params[:name] = "securo"
                          params[:description] = "secure group"
                        end.body[:security_group]
      security_group_id = security_group[:id]

      response = session.compute_service.request :delete_security_group do |params|
        params[:id] = security_group_id
      end

      response.status.must_equal 202
      response.headers.wont_be_nil
    end


    validate_response 'invalid security group id type is provided' do
      string_id = 'stringyID'

      response = session.compute_service.request :delete_security_group do |params|
        params[:id] = string_id
      end

      response.status.must_equal 400
      response.headers.wont_be_nil
      response.body.wont_be_nil
      response.body["badRequest"].wont_be_nil
      response.body["badRequest"]["message"].must_equal "Security group id should be integer"
    end


    validate_response 'non existent security group id is provided' do
      security_group_id = 99999

      response = session.compute_service.request :delete_security_group do |params|
        params[:id] = security_group_id
      end

      response.status.must_equal 404
      response.headers.wont_be_nil
      response.body.wont_be_nil
      response.body["itemNotFound"].wont_be_nil
      response.body["itemNotFound"]["message"].must_equal "Security group #{ security_group_id } not found."
    end


  end

end