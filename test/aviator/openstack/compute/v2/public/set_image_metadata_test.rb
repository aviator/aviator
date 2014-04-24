require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/public/set_image_metadata' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |p|
        p[:id]       = 'doesnt matter'
        p[:metadata] = {}
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
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'public', 'set_image_metadata.rb')
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
      metadata = {
        foo: 'lorem',
        bar: 'ipsum'
      }

      body = {
        metadata: metadata
      }

      request = klass.new(get_session_data) do |p|
        p[:id]       = 'doesnt matter'
        p[:metadata] = metadata
      end

      request.body.must_equal body
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
      create_request.http_method.must_equal :put
    end


    validate_attr :required_params do
      klass.required_params.must_equal [:id, :metadata]
    end


    validate_attr :url do
      service_spec = get_session_data[:catalog].find { |s| s[:type] == 'compute' }
      image_id     = 'doesnt matter'
      url          = "#{ service_spec[:endpoints].find{|e| e[:interface] == 'public'}[:url] }/images/#{ image_id }/metadata"

      request = create_request do |params|
        params[:id]       = image_id
        params[:metadata] = {}
      end

      request.url.must_equal url
    end


    validate_response 'valid image id is provided' do
      # must be hardcoded so as not to inadvertently alter random resources
      # in case the corresponding cassette is deleted and
      # this requires image that the user has modify access
      image_id = '2755c6d2-2978-4053-a728-f77388e24bec'

      new_metadata = {
        foo: 'lorem',
        bar: 'ipsum'
      }

      response = session.compute_service.request :set_image_metadata do |params|
        params[:id]       = image_id
        params[:metadata] = new_metadata
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:metadata].wont_be_nil
      response.body[:metadata].must_equal new_metadata.stringify_keys
      response.headers.wont_be_nil
    end


    validate_response 'invalid image id is provided' do
      image_id = 'abogusmetadataidthatdoesnotexist'

      response = session.compute_service.request :set_image_metadata do |params|
        params[:id]       = image_id
        params[:metadata] = { any: 'value' }
      end

      response.status.must_equal 404
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


  end

end
