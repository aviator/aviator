require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/requests/v2/public/create_server' do

    def create_request(session_data = get_session_data)
      image_id  = session.compute_service.request(:list_images).body[:images].first[:id]
      flavor_id = session.compute_service.request(:list_flavors).body[:flavors].first[:id]

      klass.new(session_data) do |params|
        params[:imageRef]  = image_id
        params[:flavorRef] = flavor_id
        params[:name] = 'Aviator Server'
      end
    end


    def get_session_data
      session.send :auth_response
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'public', 'create_server.rb')
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
      request = create_request

      klass.body?.must_equal true
      request.body?.must_equal true
      request.body.wont_be_nil
    end


    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :public
    end


    validate_attr :headers do
      headers = { 'X-Auth-Token' => get_session_data[:body][:access][:token][:id] }

      request = create_request

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :post
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal [
        :accessIPv4,
        :accessIPv6,
        :adminPass,
        :key_name,
        :metadata,
        :networks,
        :personality
      ]
    end


    validate_attr :required_params do
      klass.required_params.must_equal [
        :imageRef,
        :flavorRef,
        :name
      ]
    end


    validate_attr :url do
      service_spec = get_session_data[:body][:access][:serviceCatalog].find{|s| s[:type] == 'compute' }
      url          = "#{ service_spec[:endpoints][0][:publicURL] }/servers"

      image_id  = session.compute_service.request(:list_images).body[:images].first[:id]
      flavor_id = session.compute_service.request(:list_flavors).body[:flavors].first[:id]


      request = create_request do |params|
        params[:imageRef]  = image_id
        params[:flavorRef] = flavor_id
        params[:name] = 'Aviator Server'
      end

      request.url.must_equal url
    end
    
    
    validate_attr :param_aliases do
      aliases = {
        :access_ipv4 => :accessIPv4,
        :access_ipv6 => :accessIPv6,
        :admin_pass  => :adminPass,
        :image_ref   => :imageRef,
        :flavor_ref  => :flavorRef
      }
      
      klass.param_aliases.must_equal aliases
    end
    

    validate_response 'parameters are provided' do
      image_id  = session.compute_service.request(:list_images).body[:images].first[:id]
      flavor_id = session.compute_service.request(:list_flavors).body[:flavors].first[:id]

      response = session.compute_service.request :create_server do |params|
        params[:imageRef]  = image_id
        params[:flavorRef] = flavor_id
        params[:name] = 'Aviator Server'
      end

      response.status.must_equal 202
      response.body.wont_be_nil
      response.body[:server].wont_be_nil
      response.headers.wont_be_nil
    end


    validate_response 'the flavorRef parameter is invalid' do
      image_id = session.compute_service.request(:list_images).body[:images].first[:id]

      response = session.compute_service.request :create_server do |params|
        params[:imageRef] = image_id
        params[:flavorRef] = 'invalidvalue'
        params[:name] = 'Aviator Server'
      end

      response.status.must_equal 400
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


    validate_response 'the adminPass parameter is provided' do
      image_id   = session.compute_service.request(:list_images).body[:images].first[:id]
      flavor_id  = session.compute_service.request(:list_flavors).body[:flavors].first[:id]
      admin_pass = '4d764cc09a88b3'

      response = session.compute_service.request :create_server do |params|
        params[:imageRef]  = image_id
        params[:flavorRef] = flavor_id
        params[:name]      = 'Aviator Server'
        params[:adminPass] = admin_pass
      end

      response.status.must_equal 202
      response.body.wont_be_nil
      response.body[:server].wont_be_nil
      response.body[:server][:adminPass].must_equal admin_pass
      response.headers.wont_be_nil
    end

  end

end
