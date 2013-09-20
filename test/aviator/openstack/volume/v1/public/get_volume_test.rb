require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/volume/v1/public/get_volume' do

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


    def klass
      @klass ||= helper.load_request('openstack', 'volume', 'v1', 'public', 'get_volume.rb')
    end


    validate_attr :anonymous? do
      klass.anonymous?.must_equal false
    end


    validate_attr :api_version do
      klass.api_version.must_equal :v1
    end


    validate_attr :body do
      klass.body?.must_equal false

      request = create_request do |params|
                  params[:id] = 'doesntmatter'
                end

      request.body?.must_equal false
    end


    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :public
    end


    validate_attr :headers do
      headers = { 'X-Auth-Token' => get_session_data[:access][:token][:id] }

      request = create_request do |params|
                  params[:id] = 'doesntmatter'
                end

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      request = create_request do |params|
                  params[:id] = 'doesntmatter'
                end

      request.http_method.must_equal :get
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal []
    end


    validate_attr :required_params do
      klass.required_params.must_equal [:id]
    end


    validate_attr :url do
      service_spec = get_session_data[:access][:serviceCatalog].find{|s| s[:type] == 'volume' }
      volume_id    = '52415800-8b69-11e0-9b19-734f000004d2'
      url          = "#{ service_spec[:endpoints][0][:publicURL] }/volumes/#{ volume_id }"

      request = create_request do |p|
        p[:id] = volume_id
      end

      request.url.must_equal url
    end


    validate_response 'a valid volume id is provided' do

      volume_id = session.volume_service.request(:list_volumes).body['volumes'].first['id']

      response = session.volume_service.request :get_volume do |params|
        params[:id] = volume_id
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:volume].wont_be_nil
      response.body[:volume][:id].must_equal volume_id
      response.headers.wont_be_nil
    end

    validate_response 'an invalid volume id is provided' do
      volume_id = 'bogusserveridthatdoesntexist'

      response = session.volume_service.request :get_volume do |params|
        params[:id] = volume_id
      end

      response.status.must_equal 404
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end

  end
end
