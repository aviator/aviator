require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/admin/add_security_group' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |params|
                  params[:id]   = 'server-id'
                  params[:name] = 'sec-group-name'
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
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'admin', 'add_security_group.rb')
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
      sec_name = "sec-group-name"

      body = {
        "addSecurityGroup" => {
          "name" => sec_name
        }
      }

      request = klass.new(get_session_data) do |p|
        p[:id]   = "server-id"
        p[:name] = sec_name
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


    validate_attr :required_params do
      klass.required_params.must_equal [:id, :name]
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal []
    end


    validate_attr :url do
      service_spec = get_session_data[:access][:serviceCatalog].find{ |s| s[:type] == 'compute' }
      server_id    = 'sampleId'
      url          = "#{ service_spec[:endpoints][0][:adminURL] }/servers/#{ server_id }/action"

      request = create_request do |params|
        params[:id]   = server_id
        params[:name] = 'sampleName'
      end

      request.url.must_equal url
    end


    validate_response 'valid params are provided' do
      service   = session.compute_service
      server_id = service.request(:list_servers).body[:servers].first[:id]

      sec_group_response = service.request :create_security_group do |params|
        params[:name]         = 'securitea'
        params[:description]  = 'security with a tea'
      end

      response = service.request :add_security_group do |params|
        params[:id]   = server_id
        params[:name] = sec_group_response.body[:security_group][:name]
      end

      response.status.must_equal 202
      response.headers.wont_be_nil
      response.body.must_be_empty
    end


    validate_response 'associated instance and security group are provided' do
      service   = session.compute_service
      server    = service.request(:list_servers).body[:servers].first
      sec_group = service.request(:list_security_groups).body[:security_groups].last

      response = service.request :add_security_group do |params|
        params[:id]   = server[:id]
        params[:name] = sec_group[:name]
      end

      response.status.must_equal 400
      response.headers.wont_be_nil
      response.body["badRequest"].wont_be_empty
      response.body["badRequest"]["message"].must_equal "Security group #{ sec_group[:id] } is already associated with the instance #{ server[:id] }"
    end


    validate_response 'non existent server is provided' do
      service   = session.compute_service
      server_id = 'bogus-doesnt-exist'
      sec_group = service.request(:list_security_groups).body[:security_groups].last

      response = service.request :add_security_group do |params|
        params[:id]   = server_id
        params[:name] = sec_group[:name]
      end

      response.status.must_equal 404
      response.headers.wont_be_nil
      response.body["itemNotFound"].wont_be_empty
      response.body["itemNotFound"]["message"].must_equal "Instance #{ server_id } could not be found."
    end


    validate_response 'non existent security group is provided' do
      service        = session.compute_service
      server_id      = service.request(:list_servers).body[:servers].first[:id]
      sec_group_name = 'bogus-doesnt-exist'
      project_id     = session.send(:auth_info)[:access][:token][:tenant][:id]

      response = service.request :add_security_group do |params|
        params[:id]   = server_id
        params[:name] = sec_group_name
      end

      response.status.must_equal 404
      response.headers.wont_be_nil
      response.body["itemNotFound"].wont_be_empty
      response.body["itemNotFound"]["message"].must_equal "Security group #{ sec_group_name } not found for project #{ project_id }."
    end

  end

end
