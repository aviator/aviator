require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/volume/v1/public/list_volumes' do

    def create_request(session_data = new_session_data)
      klass.new(session_data)
    end


    def new_session_data
      service = Aviator::Service.new(
        provider: Environment.openstack_admin[:provider],
        service:  Environment.openstack_admin[:auth_service][:name]
      )

      bootstrap = RequestHelper.admin_bootstrap_session_data

      response = service.request :create_token, session_data: bootstrap do |params|
        auth_credentials = Environment.openstack_admin[:auth_credentials]
        auth_credentials.each { |key, value| params[key] = auth_credentials[key] }
      end

      response.body
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'volume', 'v1', 'public', 'list_volumes.rb')
    end

    validate_attr :anonymous? do
      klass.anonymous?.must_equal false
    end


    validate_attr :api_version do
      klass.api_version.must_equal :v1
    end


    validate_attr :body do
      klass.body?.must_equal false
      create_request.body?.must_equal false
    end


    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :public
    end


    validate_attr :headers do
      session_data = new_session_data

      headers = { 'X-Auth-Token' => session_data[:access][:token][:id] }

      request = create_request(session_data)

      request.headers.must_equal headers
    end

    validate_attr :optional_params do
      klass.optional_params.must_equal [
        :details,
        :status,
        :availability_zone,
        :bootable,
        :display_name,
        :display_description,
        :volume_type,
        :snapshot_id,
        :size
      ]
    end


    validate_attr :required_params do
      klass.required_params.must_equal []
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :get
    end

    validate_response 'no parameters are provided' do
      service = Aviator::Service.new(
        provider: 'openstack',
        service:  'volume',
        default_session_data: new_session_data
      )

      response = service.request :list_volumes

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:volumes].length.wont_equal 0
      response.headers.wont_be_nil
    end

    validate_response 'parameters are invalid' do
      service = Aviator::Service.new(
        provider: 'openstack',
        service:  'volume',
        default_session_data: new_session_data
      )

      response = service.request :list_volumes do |params|
        params[:display_name] = "derpderp"
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:volumes].length.must_equal 0
      response.headers.wont_be_nil
    end

    validate_response 'parameters are valid' do
      service = Aviator::Service.new(
        provider: 'openstack',
        service:  'volume',
        default_session_data: new_session_data
      )

      response = service.request :list_volumes do |params|
        params[:details] = true
        params[:display_name] = 'test'
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:volumes].length.must_equal 1
      response.headers.wont_be_nil
    end
  end

end
