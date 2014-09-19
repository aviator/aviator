require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/requests/v2/public/add_floating_ip' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |params|
                  params[:server_id] = 0
                  params[:address] = "1.1.1.1"
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
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'public', 'add_floating_ip.rb')
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
      klass.optional_params.must_equal []
    end


    validate_attr :required_params do
      klass.required_params.must_equal [:server_id, :address]
    end


    validate_attr :url do
      service_spec = get_session_data[:body][:access][:serviceCatalog].find{|s| s[:type] == 'compute' }
      url          = "#{ service_spec[:endpoints][0][:publicURL] }/servers/0/action"

      request = create_request

      request.url.must_equal url
    end


    validate_response 'valid params are provided' do
      response = session.compute_service.request :add_floating_ip, :api_version => :v2 do |params|
        params[:server_id] = "d30ae033-e714-41bc-8130-1b89352f50ee"
        params[:address] = "192.168.42.129"
      end

      response.status.must_equal 202
      response.headers.wont_be_nil
    end

  end

end
