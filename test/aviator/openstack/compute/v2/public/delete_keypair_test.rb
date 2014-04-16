require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/public/delete_keypair' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |params|
                  params[:keypair_name] = "keypair to delete"
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
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'public', 'delete_keypair.rb')
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
      klass.api_version.must_equal :v2
    end

    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :public
    end

    validate_attr :headers do
      headers = { 'X-Auth-Token' => get_session_data[:access][:token][:id] }

      request = create_request

      request.headers.must_equal headers
    end

    validate_attr :http_method do
      create_request.http_method.must_equal :delete
    end

    validate_attr :required_params do
      klass.required_params.must_equal [:keypair_name]
    end

    validate_attr :url do
      keypair_name = "keypair to delete".gsub(' ', '%20')
      service_spec = get_session_data[:access][:serviceCatalog].find{ |s| s[:type] == 'compute' }
      url          = "#{ service_spec[:endpoints][0][:publicURL] }/os-keypairs/#{ keypair_name }"

      request = create_request

      request.url.must_equal url
    end

    validate_response 'valid parameters are provided' do
      session.compute_service.request :create_or_import_keypair do |params|
        params[:name] = "keypair to delete"
      end

      response = session.compute_service.request :delete_keypair do |params|
        params[:keypair_name] = "keypair to delete"
      end

      response.status.must_equal 202

      response = session.compute_service.request :list_keypairs
      names = response.body[:keypairs].collect { |k| k[:name] }

      names.include?("keypair to delete").must_equal false
    end
  end
end