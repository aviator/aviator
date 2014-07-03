require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/public/list_image_metadata' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda { |p| p[:id] = 'doesnt matter' }

      klass.new(session_data, &block)
    end


    def get_session_data
      session.send :auth_info
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'public', 'list_image_metadata.rb')
    end


    def session
      unless @session
        @session = Aviator::Session.new(
          :config_file => Environment.path,
          :environment => 'openstack_member'
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


    validate_attr :required_params do
      klass.required_params.must_equal [:id]
    end


    validate_attr :url do
      image_id     = 'doesnt matter'
      service_spec = get_session_data[:access][:serviceCatalog].find{|s| s[:type] == 'compute' }
      url          = "#{ service_spec[:endpoints][0][:publicURL] }/images/#{ image_id }/metadata"

      request      = create_request { |p| p[:id] = image_id }

      request.url.must_equal url
    end


    validate_response 'valid image id is provided' do
      service  = session.compute_service

      images   = service.request :list_images
      image_id = images.body[:images].first[:id]

      response = service.request :list_image_metadata do |params|
        params[:id] = image_id
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:metadata].length.wont_equal 0
      response.headers.wont_be_nil
    end


    validate_response 'invalid image id is provided' do
      service  = session.compute_service
      image_id = 'invalidimageid'

      response = service.request :list_image_metadata do |params|
        params[:id] = image_id
      end

      response.status.must_equal 404
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end

  end

end
