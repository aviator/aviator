require 'test_helper'
require 'open-uri'

class Aviator::Test

  describe 'aviator/openstack/image/v1/admin/create_image' do

    def create_request(session_data = get_session_data)
      klass.new(session_data)
    end


    def get_session_data
      session.send :auth_info
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'image', 'v1', 'admin', 'create_image.rb')
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
        'Content-Type' => 'application/octet-stream'
      }

      request = create_request

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :post
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal [
        :id,
        :name,
        :disk_format,
        :container_format,
        :store,
        :owner,
        :min_ram,
        :min_disk,
        :checksum,
        :is_public,
        :is_protected,
        :copy_from,
        :file,
        :properties
      ]
    end


    validate_attr :required_params do
      klass.required_params.must_equal []
    end


    validate_attr :url do
      service_spec = get_session_data[:access][:serviceCatalog].find{|s| s[:type] == 'image' }
      uri          = URI(service_spec[:endpoints][0][:publicURL])
      url          = "#{ uri.scheme }://#{ uri.host }:#{ uri.port.to_s }/v1/images"

      create_request.url.must_equal url
    end

    validate_response 'valid params are provided' do
      response = session.image_service.request :create_image do |params|
        params[:name]             = 'CirrOS'
        params[:copy_from]        = 'http://download.cirros-cloud.net/0.3.1/cirros-0.3.1-x86_64-disk.img'
        params[:disk_format]      = 'ari'
        params[:container_format] = 'ari'
      end

      response.status.must_equal 201
      response.headers.wont_be_nil
    end

    validate_response 'no parameters are provided' do
      images          = session.image_service.request(:list_public_images).body[:images]
      response        = session.image_service.request(:create_image)
      updated_images  = session.image_service.request(:list_public_images).body[:images]

      response.status.must_equal 201
      response.body.wont_be_nil
      updated_images.length.must_equal(images.length + 1)
    end

    validate_response 'invalid copy from url is provided' do
      response = session.image_service.request :create_image do |params|
        params[:name]       = 'test image'
        params[:copy_from]  = 'someinvalidurl'
      end

      response.status.must_equal 400
      response.headers.wont_be_nil
    end

    validate_response 'invalid disk format is provided' do
      response = session.image_service.request :create_image do |params|
        params[:name]         = 'test image'
        params[:disk_format]  = 'xxx'
      end

      response.status.must_equal 400
      response.headers.wont_be_nil
    end

    validate_response 'invalid container format is provided' do
      response = session.image_service.request :create_image do |params|
        params[:name]             = 'test image'
        params[:container_format] = 'xxx'
      end

      response.status.must_equal 400
      response.headers.wont_be_nil
    end

    validate_response 'existing image id is provided' do
      image = session.image_service.request(:create_image).body[:image]

      response = session.image_service.request :create_image do |params|
        params[:name] = 'test image'
        params[:id]   = image[:id]
      end

      response.status.must_equal 409
      response.headers.wont_be_nil
    end

    validate_response 'existing image id is provided' do
      image = session.image_service.request(:create_image).body[:image]

      response = session.image_service.request :create_image do |params|
        params[:name] = 'test image'
        params[:id]   = image[:id]
      end

      response.status.must_equal 409
      response.headers.wont_be_nil
    end

    validate_response 'valid file parameter is provided' do
      tmp_file = "/tmp/" << Digest::SHA256.hexdigest("aviator-image-test-#{Socket.gethostname}")
      file = nil

      if File.exists? tmp_file
        file = File.open(tmp_file, "rb")
      else
        File.open(tmp_file, "wb") do |saved_file|
          open('http://download.cirros-cloud.net/0.3.1/cirros-0.3.1-x86_64-disk.img', 'rb') do |read_file|
            saved_file.write(read_file.read)
          end

          file = saved_file
        end
      end

      response = session.image_service.request :create_image do |params|
        params[:name]         = 'test image'
        params[:file]         = file.path
        params[:disk_format]  = 'ami'
      end

      response.status.must_equal 201
      response.headers.wont_be_nil
    end

    validate_response 'invalid file parameter is provided' do
      request = lambda do
        response = session.image_service.request :create_image do |params|
          params[:name] = 'test image'
          params[:file] = 'imagedoesntexist'
        end
      end

      request.must_raise Errno::ENOENT
    end

  end

end
