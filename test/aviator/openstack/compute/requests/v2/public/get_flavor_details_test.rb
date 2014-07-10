require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/requests/v2/public/get_flavor_details' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |params|
                  params[:id] = 0
                end

      klass.new(session_data, &block)
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


    def get_session_data
      session.send :auth_info
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'public', 'get_flavor_details.rb')
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
      headers = { 'X-Auth-Token' => get_session_data[:access][:token][:id] }

      request = create_request(get_session_data)

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :get
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal []
    end


    validate_attr :required_params do
      klass.required_params.must_equal [:id]
    end


    validate_attr :url do
      session_data = get_session_data
      service_spec = get_session_data[:access][:serviceCatalog].find{|s| s[:type] == 'compute' }
      flavor_id    = 3
      url          = "#{ service_spec[:endpoints][0][:publicURL] }/flavors/#{ flavor_id }"

      request = klass.new(session_data) do |p|
        p[:id] = flavor_id
      end

      request.url.must_equal url
    end


    validate_response 'parameters are provided' do
      response = session.compute_service.request :get_flavor_details do |p|
        p[:id] = 3
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


    validate_response 'invalid parameters are provided' do
      response = session.compute_service.request :get_flavor_details do |p|
        p[:id] = 0
      end

      response.status.must_equal 404
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end

  end

end
