require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/image/v1/public/list_public_images' do

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


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'image', 'v1', 'public', 'list_public_images.rb')
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
      headers = { 'X-Auth-Token' => get_session_data[:access][:token][:id] }

      request = create_request

      request.headers.must_equal headers
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal [
        :name,
        :container_format,
        :disk_format,
        :status,
        :size_min,
        :size_max,
        :sort_key,
        :sort_dir
      ]
    end


    validate_attr :required_params do
      klass.required_params.must_equal []
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :get
    end


    validate_response 'no parameters are provided' do
      response = session.image_service.request :list_public_images

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:images].length.wont_equal 0
      response.headers.wont_be_nil
    end


    validate_response 'filtering with matches' do
      response = session.image_service.request :list_public_images do |p|
        p[:name] = '64Bit Ubuntu 12.04'
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:images].length.must_equal 1
      response.headers.wont_be_nil
    end


    validate_response 'filtering with no matches' do
      response = session.image_service.request :list_public_images do |p|
        p[:name] = 'does-not-match-any-image'
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:images].length.must_equal 0
      response.headers.wont_be_nil
    end

  end
end
