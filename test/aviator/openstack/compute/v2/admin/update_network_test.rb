require_relative '../../../../../test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/admin/update_network' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |params|
                  params[:id] = 'theNetwork'
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
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'admin', 'update_network.rb')
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
      klass.api_version.must_equal :v2
    end


    validate_attr :body do
      klass.body?.must_equal true
      create_request.body?.must_equal true
    end


    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :admin
    end


    validate_attr :headers do
      session_data = get_session_data

      headers = { 'X-Auth-Token' => session_data.token }

      create_request(session_data).headers.must_equal headers
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :post
    end


    validate_attr :required_params do
      klass.required_params.must_equal [:id]
    end


    validate_attr :url do
      network_id = 'networkId'

      service_spec = get_session_data[:catalog].find{ |s| s[:type] == 'compute' }
      url          = "#{ service_spec[:endpoints].find{|e| e[:interface] == 'admin'}[:url] }/os-networks/#{network_id}/action"


      request = klass.new(get_session_data) do |p|
        p[:id] = network_id
      end

      request.url.must_equal url
    end

  end

end
