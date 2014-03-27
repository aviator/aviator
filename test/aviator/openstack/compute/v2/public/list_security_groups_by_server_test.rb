require 'test_helper'
require 'pry'
class Aviator::Test

  describe 'aviator/openstack/compute/v2/public/list_security_groups_by_server' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda { |params| params[:server_id] = 0 }
      klass.new(session_data, &block)
    end

    def get_session_data
      session.send :auth_info
    end

    def helper
      Aviator::Test::RequestHelper
    end

    def klass
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'public', 'list_security_groups_by_server.rb')
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

      request = create_request(session_data)

      request.headers.must_equal headers
    end

    validate_attr :http_method do
      create_request.http_method.must_equal :get
    end

    validate_attr :optional_params do
      klass.optional_params.must_equal []
    end

    validate_attr :required_params do
      klass.required_params.must_equal [:server_id]
    end

    validate_attr :url do
      service_spec = get_session_data[:access][:serviceCatalog].find{ |s| s[:type] == 'compute' }
      server_id = "serverID"
      url = "#{ service_spec[:endpoints][0][:publicURL] }/servers/#{ server_id }/os-security-groups"

      request = create_request do |params|
        params[:server_id] = server_id
      end

      request.url.must_equal url
    end

    validate_response 'invalid parameters are provided' do
      response = session.compute_service.request :list_security_groups_by_server do |params|
        params[:server_id] = "xxx"
      end

      response.status.must_equal 404
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end

    validate_response 'valid parameters are provided' do
      image_id  = session.image_service.request(:list_public_images).body[:images].first[:id]
      flavor_id = session.compute_service.request(:list_flavors).body[:flavors].first[:id]

      server_response = session.compute_service.request :create_server do |params|
        params[:imageRef]  = image_id
        params[:flavorRef] = flavor_id
        params[:name] = 'Aviator Server Sec'
      end

      response = session.compute_service.request :list_security_groups_by_server do |params|
        params[:server_id] = server_response.body[:server][:id]
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.headers.wont_be_nil
      response.body[:security_groups].length.wont_equal 0
    end
  end
end
