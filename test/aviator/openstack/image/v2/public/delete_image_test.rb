require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/image/v2/public/delete_image' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |params|
                  params[:id] = 0
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
      @klass ||= helper.load_request('openstack', 'image', 'v2', 'public', 'delete_image.rb')
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
      create_request.http_method.must_equal :delete
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal []
    end


    validate_attr :required_params do
      klass.required_params.must_equal [:image_id]
    end


    validate_attr :url do
      v2_base_url = get_session_data[:catalog].find { |s| s[:type] == 'image' }[:endpoints].find{|a| a[:interface] == 'public'}[:url]
      image_id    = 'it does not matter for this test'
      url         = "#{ v2_base_url }/v2/images/#{ image_id }"

      request = klass.new(get_session_data) do |p|
        p[:id] = image_id
      end

      request.url.must_equal url
    end


    validate_response 'valid params are provided' do
      image    = session.image_service.request(:create_image).body[:image]
      image_id = image[:id]

      response = session.image_service.request(:delete_image, api_version: :v2) do |params|
        params[:id] = image_id
      end

      response.status.must_equal 204
      response.headers.wont_be_nil
    end


    validate_response 'invalid params are provided' do
      image_id = 'bogusimageid'

      response = session.image_service.request(:delete_image, api_version: :v2) do |params|
        params[:id] = image_id
      end

      response_body = -> { response.body }

      response.status.must_equal 404
      response.headers.wont_be_nil
      response_body.must_raise JSON::ParserError
    end

  end

end