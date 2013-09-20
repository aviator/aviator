require 'test_helper'

class Aviator::Test
  describe 'aviator/openstack/volume/v1/public/update_volume' do
    def create_request(session_data = get_session_data, &block)
      volume_id  = session.volume_service.request(:list_volumes).body[:volumes].first[:id]

      klass.new(session_data, &block)
    end

    def get_session_data
      session.send :auth_info
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'volume', 'v1', 'public', 'update_volume.rb')
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
      klass.api_version.must_equal :v1
    end


    validate_attr :body do
      request = create_request{|p| p[:id] = 0 }

      klass.body?.must_equal true
      request.body?.must_equal true
      request.body.wont_be_nil
    end

    validate_attr :headers do
      headers = { 'X-Auth-Token' => get_session_data[:access][:token][:id] }

      request = create_request{|p| p[:id] = 0 }

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      create_request{|p| p[:id] = 0 }.http_method.must_equal :put
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal [
        :display_name,
        :display_description
      ]
    end

    validate_attr :required_params do
      klass.required_params.must_equal [
        :id
      ]
    end

    validate_attr :url do
      service_spec = get_session_data[:access][:serviceCatalog].find{|s| s[:type] == 'volume' }
      volume_id    = 'doesitmatter'
      url          = "#{ service_spec[:endpoints][0][:publicURL] }/volumes/#{ volume_id }"

      request = create_request do |params|
        params[:id] = volume_id
      end

      request.url.must_equal url
    end

    validate_response 'valid volume id is provided' do
      volume    = session.volume_service.request(:list_volumes).body[:volumes].first
      volume_id = volume[:id]
      new_name  = 'Aviator Test Update Volume'

      response = session.volume_service.request :update_volume do |params|
        params[:id]           = volume_id
        params[:display_name] = new_name
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:volume].wont_be_nil
      response.body[:volume][:display_name].must_equal new_name
      response.headers.wont_be_nil
    end

    validate_response 'invalid volume id is provided' do
      volume_id = 'ithinkiexist'

      response = session.volume_service.request :update_volume do |params|
        params[:id]   = volume_id
        params[:display_name] = 'it does not matter'
      end

      response.status.must_equal 404
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end
  end
end
