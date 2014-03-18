require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/image/v1/admin/update_image' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |params|
                  params[:id] = 'image-id'
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
      @klass ||= helper.load_request('openstack', 'image', 'v1', 'admin', 'update_image.rb')
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
      klass.api_version.must_equal :v1
    end


    validate_attr :body do
      request = create_request

      klass.body?.must_equal false
      request.body?.must_equal false
    end


    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :admin
    end


    validate_attr :headers do
      headers = {
        'X-Auth-Token' => get_session_data[:access][:token][:id],
      }

      request = create_request

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :put
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal [
        :name,
        :disk_format,
        :container_format,
        :owner,
        :min_ram,
        :min_disk,
        :checksum,
        :is_public,
        :is_protected,
        :properties
      ]
    end


    validate_attr :required_params do
      klass.required_params.must_equal [:id]
    end


    validate_attr :url do
      session_data = get_session_data
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'image' }
      image_id     = "some-image-id"
      url          = "#{ service_spec[:endpoints][0][:publicURL] }/v1/images/#{ image_id }"

      request = klass.new(session_data) do |p|
        p[:id] = image_id
      end

      request.url.must_equal url
    end


    validate_response 'valid params are provided' do
      image = session.image_service.request(:list_public_images).body[:images].first
      updated_name = image[:name] << "aviatorImageOS"

      response = session.image_service.request :update_image do |params|
        params[:id]   = image[:id]
        params[:name] = updated_name
      end

      details_response = session.compute_service.request :get_image_details do |params|
        params[:id] = image[:id]
      end

      response.status.must_equal 200
      response.headers.wont_be_nil
      response.body.wont_be_nil
      response.body[:image].wont_be_nil
      response.body[:image][:name].must_equal updated_name

      details_response.status.must_equal 200
      details_response.headers.wont_be_nil
      details_response.body.wont_be_nil
      details_response.body[:image][:name].must_equal updated_name
    end


    validate_response 'invalid id parameter is provided' do
      response = session.image_service.request(:update_image) do |params|
        params[:id] = 'bogus-nonexistent-id'
      end

      response.status.must_equal 404
      response.headers.wont_be_nil
    end
  end

end
