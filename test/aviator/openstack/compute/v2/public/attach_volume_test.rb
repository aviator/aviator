require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/public/attach_volume' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |params|
                  params[:server_id] = 'caae3c89-80c4-test-test-a9d7c3fce4dc'
                  params[:volume_id] = '56121be0-1d25-test-test-77e5c21449c5'
                  params[:device] = '/dev/xvdb'
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
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'public', 'attach_volume.rb')
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

    def create_volume
      response = session.volume_service.request :create_volume do |params|
        params[:display_name]         = 'Aviator Volume Test Name'
        params[:display_description]  = 'Aviator Volume Test Description'
        params[:size]                 = '1'
      end
      response
    end

    def create_server
      image_id  = session.compute_service.request(:list_images).body[:images].first[:id]
      flavor_id = session.compute_service.request(:list_flavors).body[:flavors].first[:id]
      
      response = session.compute_service.request :create_server do |params|
        params[:imageRef]  = image_id
        params[:flavorRef] = flavor_id
        params[:name] = 'Aviator Server'
      end
      response
    end

    validate_attr :anonymous? do
      klass.anonymous?.must_equal false
    end


    validate_attr :api_version do
      klass.api_version.must_equal :v2
    end


    validate_attr :body do
      request = create_request

      klass.body?.must_equal true
      request.body?.must_equal true
      request.body.wont_be_nil
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
      create_request.http_method.must_equal :post
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal []
    end


    validate_attr :required_params do
      klass.required_params.must_equal [:server_id, :volume_id, :device]
    end


    validate_attr :url do
      session_data = get_session_data
      service_spec = session_data[:catalog].find{|s| s[:type] == 'compute' }
      server_id    = 'caae3c89-80c4-test-test-a9d7c3fce4dc'
      volume_id    = '56121be0-1d25-test-test-77e5c21449c5'
      device       = '/dev/xvdb'
      url          = "#{ service_spec[:endpoints].find{|a| a[:interface] == 'public'}[:url] }/servers/#{ server_id }/os-volume_attachments"

      request = create_request do |params|
        params[:server_id]  = server_id
        params[:volume_id]  = volume_id
        params[:device]     = device
      end

      request.url.must_equal url
    end


    validate_response 'valid parameters are provided' do
      server_list_response  = session.compute_service.request :list_servers
      volume_list_response  = session.volume_service.request  :list_volumes
      servers = server_list_response.body[:servers]
      volumes = volume_list_response.body[:volumes]
      
      if volumes.empty?
        created_volume = create_volume
        volume_id  = created_volume.body[:volume][:id]    
      else
        volume_id  = volumes[-1][:id]
      end
      
      if servers.empty?
        created_server = create_server
        server_id = created_server.body[:server][:id]
      else
        server_id = servers[-1][:id]  
      end
      device     = '/dev/xvdb'

      response = session.compute_service.request :attach_volume do |params|
        params[:server_id]  = server_id
        params[:volume_id]  = volume_id
        params[:device]     = device
      end
     
      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:volumeAttachment].wont_be_nil
      response.headers.wont_be_nil
    end

    validate_response 'invalid volumeId is provided' do
      response = session.compute_service.request :attach_volume do |params|
        params[:server_id]  = 'invalidServerId'
        params[:volume_id]  = 'invalidVolumeId'
        params[:device]     = '/dev/xvdb'
      end
      
      response.status.must_equal 400
      response.headers.wont_be_nil
      response.body["badRequest"].wont_be_nil
      response.body["badRequest"]["message"].must_equal "Bad volumeId format: volumeId is not in proper format (invalidVolumeId)"
    end

    validate_response 'non existent server is provided' do
      volume_list_response  = session.volume_service.request  :list_volumes
      volumes = volume_list_response.body[:volumes]
      
      if volumes.empty?
        created_volume = create_volume
        volume_id  = created_volume.body[:volume][:id]    
      else
        volume_id  = volumes[-1][:id]
      end
            
      response = session.compute_service.request :attach_volume do |params|
        params[:server_id]  = 'serverDoesntExist'
        params[:volume_id]  = volume_id
        params[:device]     = '/dev/xvdb'
      end
      
      response.status.must_equal 404
      response.headers.wont_be_nil
      response.body["itemNotFound"].wont_be_nil
      response.body["itemNotFound"]["message"].must_equal "The resource could not be found."
    end


    validate_response 'non existent volume is provided' do
      server_list_response  = session.compute_service.request :list_servers
      servers = server_list_response.body[:servers]
      
      if servers.empty?
        created_server = create_server
        server_id = created_server.body[:server][:id]
      else
        server_id = servers[-1][:id]  
      end
      
      response = session.compute_service.request :attach_volume do |params|
        params[:server_id]  = server_id
        params[:volume_id]  = '56121be0-1d25-1234-bb53-77e5c21449c5'
        params[:device]     = '/dev/xvdb'
      end

      response.status.must_equal 404
      response.headers.wont_be_nil
      response.body["itemNotFound"].wont_be_nil
      response.body["itemNotFound"]["message"].must_equal "The resource could not be found."
    end

  end

end