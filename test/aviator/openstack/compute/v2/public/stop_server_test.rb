require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/public/stop_server' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda { |params| params[:id] = 0 }
      klass.new(session_data, &block)
    end


    def get_session_data
      session.send :auth_info
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'public', 'stop_server.rb')
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

    def create_server
      nova = session.compute_service
      image = nova.request(:list_images).body[:images].first
      flavor = nova.request(:list_flavors).body[:flavors].first

      response = nova.request(:create_server) do |p|
        p[:imageRef] = image[:id]
        p[:flavorRef] = flavor[:id]
        p[:name] = 'server name'
      end

      response.body[:server]
    end

    def get_server_by_state(id, state)
      response = session.compute_service.request(:get_server) do |p|
        p[:id] = id
      end

      server = response.body[:server]
      if server[:status].downcase != state
        get_server_by_state(id, state)
      end
      server
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


    validate_attr :required_params do
      klass.required_params.must_equal [:id]
    end


    validate_attr :url do
      service_spec = get_session_data[:catalog].find{ |s| s[:type] == 'compute' }
      server_id    = 'sampleId'
      url          = "#{ service_spec[:endpoints].find{|e| e[:interface] == 'public'}[:url] }/servers/#{ server_id }/action"

      request = create_request do |params|
        params[:id] = server_id
      end

      request.url.must_equal url
    end


    validate_response 'valid params are provided' do
      service = session.compute_service

      server_id = create_server[:id]
      server = get_server_by_state(server_id, 'active')

      response = service.request :stop_server do |params|
        params[:id] = server[:id]
      end

      response.status.must_equal 202
      response.headers.wont_be_nil
    end

    validate_response 'invalid server id is provided' do
      server_id = 'abogusserveridthatdoesnotexist'

      response = session.compute_service.request :stop_server do |params|
        params[:id] = server_id
      end

      response.status.must_equal 404
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


  end

end
