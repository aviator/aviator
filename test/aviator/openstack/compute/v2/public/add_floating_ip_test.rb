require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/public/add_floating_ip' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |params|
                  params[:server_id] = 'randompassword'
                  params[:address]   = '0.0.0.0'
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
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'public', 'add_floating_ip.rb')
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
      klass.required_params.must_equal [:server_id, :address]
    end


    validate_attr :url do
      session_data = get_session_data
      service_spec = session_data[:catalog].find{|s| s[:type] == 'compute' }
      server_id    = 'testdummyID'
      url          = "#{ service_spec[:endpoints].find{|e| e[:interface] == 'public'}[:url] }/servers/#{ server_id }/action"

      request = create_request do |params|
        params[:server_id]  = server_id
        params[:address]    = '0.0.0.1'
      end

      request.url.must_equal url
    end


    validate_response 'valid parameters are provided' do
      session.compute_service.request :create_floating_ip

      server_list_response  = session.compute_service.request :list_servers
      ip_list_response      = session.compute_service.request :list_floating_ips

      server_id  = server_list_response.body[:servers][-1][:id]
      ip_address = ip_list_response.body[:floating_ips][-1][:ip]

      response = session.compute_service.request :add_floating_ip do |params|
        params[:server_id]  = server_id
        params[:address]    = ip_address
      end

      server_get_response = session.compute_service.request :get_server do |p|
        p[:id] = server_id
      end

      get_body = server_get_response.body

      response.status.must_equal 202
      response.headers.wont_be_nil

      server_get_response.status.must_equal 200
      get_body.wont_be_nil
      get_body[:server][:addresses][:private]
          .map{|a| a[:addr] == ip_address && a["OS-EXT-IPS:type"] == "floating"}.must_include true
    end


    validate_response 'non existent server is provided' do
      response = session.compute_service.request :add_floating_ip do |params|
        params[:server_id]  = 'server1doesntexist'
        params[:address]    = '0.0.0.1'
      end

      response.status.must_equal 404
      response.headers.wont_be_nil
      response.body["itemNotFound"].wont_be_nil
      response.body["itemNotFound"]["message"].must_equal "The resource could not be found."
    end


    validate_response 'non existent IP address is provided' do
      list_response = session.compute_service.request :list_servers

      response = session.compute_service.request :add_floating_ip do |params|
        params[:server_id]  = list_response.body[:servers].first[:id]
        params[:address]    = '0.0.0.1.95.9'
      end

      response.status.must_equal 404
      response.headers.wont_be_nil
      response.body["itemNotFound"].wont_be_nil
      response.body["itemNotFound"]["message"].must_equal "floating ip not found"
    end


  end

end