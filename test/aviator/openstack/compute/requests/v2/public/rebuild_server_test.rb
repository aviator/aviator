require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/requests/v2/public/rebuild_server' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |params|
                  params[:adminPass] = 'newadminpassword'
                  params[:id]        = 0
                  params[:imageRef]  = 'bogusimageref'
                  params[:name]      = 'newservername'
                end

      klass.new(session_data, &block)
    end


    def get_session_data
      session.send :auth_response
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'public', 'rebuild_server.rb')
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
        :metadata,
        :personality
      ]
    end


    validate_attr :required_params do
      klass.required_params.must_equal [
        :adminPass,
        :id,
        :imageRef,
        :name
      ]
    end


    validate_attr :url do
      service_spec = get_session_data[:body][:access][:serviceCatalog].find{|s| s[:type] == 'compute' }
      server_id    = '105b09f0b6500d36168480ad84'
      url          = "#{ service_spec[:endpoints][0][:publicURL] }/servers/#{ server_id }/action"

      request = create_request do |params|
        params[:adminPass] = 'thisdoesnotmatterforthistest'
        params[:id]        =  server_id
        params[:imageRef]  = 'thisdoesnotmatterforthistest'
        params[:name]      = 'thisdoesnotmatterforthistest'
      end

      request.url.must_equal url
    end


    validate_attr :param_aliases do
      aliases = {
        :access_ipv4 => :accessIPv4,
        :access_ipv6 => :accessIPv6,
        :admin_pass  => :adminPass,
        :image_ref   => :imageRef
      }

      klass.param_aliases.must_equal aliases
    end


    validate_response 'valid params are provided' do
      server    = session.compute_service.request(:list_servers).body[:servers].first
      server_id = server[:id]
      image     = session.compute_service.request(:list_images).body[:images].first
      image_id  = image[:id]


      response = session.compute_service.request :rebuild_server do |params|
        params[:adminPass] = 'settheadminpasswordtothis'
        params[:id]        =  server_id
        params[:imageRef]  =  image_id
        params[:name]      = 'setthenewnametothis'
      end


      response.status.must_equal 202
      response.headers.wont_be_nil
    end


    validate_response 'invalid server id is provided' do
      server_id = 'abogusserveridthatdoesnotexist'
      image     = session.compute_service.request(:list_images).body[:images].first
      image_id  = image[:id]


      response = session.compute_service.request :rebuild_server do |params|
        params[:adminPass] = 'settheadminpasswordtothis'
        params[:id]        =  server_id
        params[:imageRef]  =  image_id
        params[:name]      = 'setthenewnametothis'
      end


      response.status.must_equal 404
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


    validate_response 'invalid image id is provided' do
      server    = session.compute_service.request(:list_servers).body[:servers].first
      server_id = server[:id]
      image_id  = 'abogusimageidthatdoesnotexist'


      response = session.compute_service.request :rebuild_server do |params|
        params[:adminPass] = 'settheadminpasswordtothis'
        params[:id]        =  server_id
        params[:imageRef]  =  image_id
        params[:name]      = 'setthenewnametothis'
      end


      response.status.must_equal 400
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


  end

end