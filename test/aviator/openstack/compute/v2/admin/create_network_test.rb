require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/admin/create_network' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |p|
        p[:label] = 'network-test'
        p[:cidr]  = '10.0.10.0/24'
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
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'admin', 'create_network.rb')
    end


    def session
      unless @session
        @session = Aviator::Session.new(
          :config_file => Environment.path,
          :environment => 'openstack_admin'
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
      params = {
        :label            => 'mynetwork',
        :bridge           => 'dummy-value-for-test',
        :bridge_interface => 'dummy-value-for-test',
        :cidr             => 'dummy-value-for-test',
        :cidr_v6          => 'dummy-value-for-test',
        :dns1             => 'dummy-value-for-test',
        :dns2             => 'dummy-value-for-test',
        :gateway          => 'dummy-value-for-test',
        :gateway_v6       => 'dummy-value-for-test',
        :multi_host       => 'dummy-value-for-test',
        :project_id       => 'dummy-value-for-test',
        :vlan             => 'dummy-value-for-test'
      }

      body = {
        :network => params
      }

      request = klass.new(helper.admin_session_data) do |p|
        params.each do |k,v|
          p[k] = v
        end
      end

      request.body.must_equal body
    end


    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :admin
    end


    validate_attr :headers do
      headers = { 'X-Auth-Token' => get_session_data[:access][:token][:id] }

      request = create_request

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :post
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal [
        :bridge,
        :bridge_interface,
        :cidr,
        :cidr_v6,
        :dns1,
        :dns2,
        :gateway,
        :gateway_v6,
        :multi_host,
        :project_id,
        :vlan
      ]
    end


    validate_attr :required_params do
      klass.required_params.must_equal [:label]
    end


    validate_attr :url do
      service_spec = get_session_data[:access][:serviceCatalog].find{ |s| s[:type] == 'compute' }
      url          = "#{ service_spec[:endpoints][0][:adminURL] }/os-networks"

      request = create_request

      request.url.must_equal url
    end


    validate_response 'valid parameters are provided' do
      response = session.compute_service.request :create_network do |params|
        params[:label] = 'networktest'
        params[:cidr]  = '10.0.9.0/24'
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:network].wont_be_nil
      response.headers.wont_be_nil
    end


    validate_response 'invalid parameters are provided' do
      response = session.compute_service.request :create_network do |params|
        params[:label] = 'invalid-network!'
        params[:cidr]  = 'this-is-invalid!'
      end

      response.status.must_equal 400
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


  end

end
