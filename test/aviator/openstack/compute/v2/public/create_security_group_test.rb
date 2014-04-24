require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/public/create_security_group' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |params|
                  params[:name]        = "security group name"
                  params[:description] = "security group description"
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
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'public', 'create_security_group.rb')
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
      request = create_request

      klass.body?.must_equal true
      request.body?.must_equal true
      request.body.wont_be_nil
    end

    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :public
    end

    validate_attr :headers do
      headers = { 'X-Auth-Token' => get_session_data.token }

      request = create_request

      request.headers.must_equal headers
    end

    validate_attr :http_method do
      create_request.http_method.must_equal :post
    end

    validate_attr :optional_params do
      klass.optional_params.must_equal []
    end

    validate_attr :required_params do
      klass.required_params.must_equal [:name, :description]
    end

    validate_attr :url do
      service_spec = get_session_data[:catalog].find{ |s| s[:type] == 'compute' }
      url          = "#{ service_spec[:endpoints][0][:publicURL] }/os-security-groups"

      request = create_request

      request.url.must_equal url
    end

    validate_response 'valid parameters are provided' do
      sec_name = "security group name"
      sec_desc = "security group description"

      response = session.compute_service.request :create_security_group do |params|
        params[:name]        = sec_name
        params[:description] = sec_desc
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:security_group].length.must_equal 5
      response.body[:security_group][:name].must_equal sec_name
      response.body[:security_group][:description].must_equal sec_desc
      response.headers.wont_be_nil
    end
  end
end