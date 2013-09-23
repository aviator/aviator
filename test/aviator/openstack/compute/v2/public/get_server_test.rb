require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/public/get_server' do

    def create_request(session_data = get_session_data, &block)
      klass.new(session_data, &block)
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


    def get_session_data
      session.send :auth_info
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'public', 'get_server.rb')
    end


    validate_attr :anonymous? do
      klass.anonymous?.must_equal false
    end


    validate_attr :api_version do
      klass.api_version.must_equal :v2
    end


    validate_attr :body do
      klass.body?.must_equal false

      request = create_request do |params|
                  params[:id] = 'doesntmatter'
                end

      request.body?.must_equal false
    end


    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :public
    end


    validate_attr :headers do
      headers = { 'X-Auth-Token' => get_session_data[:access][:token][:id] }

      request = create_request do |params|
                  params[:id] = 'doesntmatter'
                end

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      request = create_request do |params|
                  params[:id] = 'doesntmatter'
                end

      request.http_method.must_equal :get
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal []
    end


    validate_attr :required_params do
      klass.required_params.must_equal [:id]
    end


    validate_attr :url do
      service_spec = get_session_data[:access][:serviceCatalog].find{|s| s[:type] == 'compute' }
      server_id    = '52415800-8b69-11e0-9b19-734f000004d2'
      url          = "#{ service_spec[:endpoints][0][:publicURL] }/servers/#{ server_id }"

      request = create_request do |p|
        p[:id] = server_id
      end

      request.url.must_equal url
    end


    validate_response 'a valid server id is provided' do
      server_id = session.compute_service.request(:list_servers).body[:servers].first[:id]

      response = session.compute_service.request :get_server do |params|
        params[:id] = server_id
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:server].wont_be_nil
      response.body[:server][:id].must_equal server_id
      response.headers.wont_be_nil
    end


    validate_response 'an invalid server id is provided' do
      server_id = 'bogusserveridthatdoesntexist'

      response = session.compute_service.request :get_server do |params|
        params[:id] = server_id
      end

      response.status.must_equal 404
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end

  end

end
