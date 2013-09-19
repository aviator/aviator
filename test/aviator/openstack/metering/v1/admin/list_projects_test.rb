require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/metering/v1/admin/projects' do

    def create_request(session_data = get_session_data)
      klass.new(session_data)
    end


    def get_session_data
      session.send :auth_info
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'metering', 'v1', 'admin', 'list_projects.rb')
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
      klass.api_version.must_equal :v1
    end


    validate_attr :body do
      request = create_request

      klass.body?.must_equal false
      request.body?.must_equal false
    end


    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :admin
    end


    validate_attr :headers do
      headers = { 'X-Auth-Token' => get_session_data[:access][:token][:id] }

      request = create_request

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :get
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal []
    end


    validate_attr :required_params do
      klass.required_params.must_equal []
    end


    validate_attr :url do
      service_spec = get_session_data[:access][:serviceCatalog].find{|s| s[:type] == 'metering' }
      uri          = URI(service_spec[:endpoints][0][:adminURL])
      url          = "#{ uri.scheme }://#{ uri.host }:#{ uri.port.to_s }/v1/projects"

      create_request.url.must_equal url
    end



    validate_response 'no parameters are provided' do
      response = session.metering_service.request :list_projects

      response.status.must_equal 200
      response.body.wont_be_nil
    end

  end

end
