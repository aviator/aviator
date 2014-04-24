require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/admin/reset_server' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |params|
                  params[:id]    = 0
                  params[:state] = 'active'
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
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'admin', 'reset_server.rb')
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
      active_state = 'active'

      body = {
        'os-resetState' => {
          'state' => active_state
        }
      }

      request = klass.new(get_session_data) do |p|
        p[:id]    = 'sampleid'
        p[:state] = active_state
      end

      request.body.must_equal body
    end


    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :admin
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
      klass.required_params.must_equal [:id, :state]
    end


    validate_attr :url do
      service_spec = get_session_data[:catalog].find{ |s| s[:type] == 'compute' }
      server_id    = 'sampleId'
      url          = "#{ service_spec[:endpoints].find{|e| e[:interface] == 'admin'}[:url] }/servers/#{ server_id }/action"

      request = create_request do |params|
        params[:id]    = server_id
        params[:state] = 'active'
      end

      request.url.must_equal url
    end


    validate_response 'valid params are provided' do
      service = session.compute_service
      server  = service.request(:list_servers).body[:servers].first

      response = service.request :reset_server do |params|
        params[:id]    = server[:id]
        params[:state] = 'active'
      end

      response.status.must_equal 202
      response.headers.wont_be_nil
    end


    validate_response 'invalid server id is provided' do
      server_id = 'abogusserveridthatdoesnotexist'

      response = session.compute_service.request :reset_server do |params|
        params[:id]    = server_id
        params[:state] = 'active'
      end

      response.status.must_equal 404
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


  end

end
