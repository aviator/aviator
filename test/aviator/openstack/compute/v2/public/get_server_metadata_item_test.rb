require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/public/get_server_metadata_item' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |p|
                  p[:id]  = 'doesnt matter'
                  p[:key] = 'doesnt matter'
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
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'public', 'get_server_metadata_item.rb')
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

      headers = { 'X-Auth-Token' => session_data.token }

      request = create_request(session_data)

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :get
    end


    validate_attr :required_params do
      klass.required_params.must_equal [:id, :key]
    end


    validate_attr :url do
      server_id     = 'doesnt matter'
      metadata_key = 'doesnt matter'
      service_spec = get_session_data[:catalog].find { |s| s[:type] == 'compute' }
      url          = "#{ service_spec[:endpoints][0][:publicURL] }/servers/#{ server_id }/metadata/#{ metadata_key }"

      request = create_request do |p|
                  p[:id]  = server_id
                  p[:key] = metadata_key
                end

      request.url.must_equal url
    end


    validate_response 'valid server id and metadata key are provided' do
      service  = session.compute_service

      servers   = service.request :list_servers
      server_id = servers.body[:servers].first[:id]

      metadata     = service.request(:list_server_metadata) { |p| p[:id] = server_id }.body[:metadata]
      metadata_key = metadata.keys.first

      response = service.request :get_server_metadata_item do |params|
        params[:id]  = server_id
        params[:key] = metadata_key
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:meta].length.wont_equal 0
      response.headers.wont_be_nil
    end


    validate_response 'invalid server id and metadata key are provided' do
      service      = session.compute_service
      server_id     = 'invalidserverid'
      metadata_key = 'doesntmatter'

      response = service.request :get_server_metadata_item do |params|
        params[:id]  = server_id
        params[:key] = metadata_key
      end

      response.status.must_equal 404
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


    validate_response 'invalid metadata key is provided' do
      service  = session.compute_service

      servers   = service.request :list_servers
      server_id = servers.body[:servers].first[:id]

      metadata_key = 'invalidmetadatakey'

      response = service.request :get_server_metadata_item do |params|
        params[:id]  = server_id
        params[:key] = metadata_key
      end

      response.status.must_equal 404
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


  end

end
