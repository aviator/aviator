require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/public/list_servers' do


    def admin_session
      unless @admin_session
        @admin_session = Aviator::Session.new(
                           config_file: Environment.path,
                           environment: 'openstack_admin'
                         )
        @admin_session.authenticate
      end

      @admin_session
    end


    def create_request(session_data = new_session_data)
      klass.new(session_data)
    end


    def new_session_data
      service = Aviator::Service.new(
        provider: Environment.openstack_admin[:provider],
        service:  Environment.openstack_admin[:auth_service][:name]
      )

      bootstrap = RequestHelper.admin_bootstrap_session_data

      response = service.request :create_token, session_data: bootstrap do |params|
        auth_credentials = Environment.openstack_admin[:auth_credentials]
        auth_credentials.each { |key, value| params[key] = auth_credentials[key] }
      end

      response.body
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'public', 'list_servers.rb')
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
      session_data = new_session_data

      headers = { 'X-Auth-Token' => session_data[:access][:token][:id] }

      request = create_request(session_data)

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :get
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal [
        :all_tenants,
        :details,
        :flavor,
        :image,
        :limit,
        :marker,
        :server,
        :status,
        'changes-since'
      ]
    end


    validate_attr :required_params do
      klass.required_params.must_equal []
    end


    validate_attr :url do
      session_data = new_session_data
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'compute' }
      url          = "#{ service_spec[:endpoints][0][:publicURL] }/servers"

      params = [
        [ :details, false      ],
        [ :flavor,  'm1.small' ],
        [ :image,   'cirros-0.3.1-x86_64-uec-ramdisk' ],
        [ :status,  'ACTIVE'                          ]
      ]

      url += "/detail" if params.first[1]

      filters = []

      params[1, params.length-1].each { |pair| filters << "#{ pair[0] }=#{ pair[1] }" }

      url += "?#{ filters.join('&') }" unless filters.empty?

      request = klass.new(session_data) do |p|
        params.each { |pair| p[pair[0]] = pair[1] }
      end


      request.url.must_equal url
    end


    validate_response 'no parameters are provided' do
      service = Aviator::Service.new(
        provider: 'openstack',
        service:  'compute',
        default_session_data: new_session_data
      )

      response = service.request :list_servers

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:servers].length.wont_equal 0
      response.headers.wont_be_nil
    end


    validate_response 'parameters are invalid' do
      service = Aviator::Service.new(
        provider: 'openstack',
        service:  'compute',
        default_session_data: new_session_data
      )

      response = service.request :list_servers do |params|
        params[:image] = "nonexistentimagenameherpderp"
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:servers].length.must_equal 0
      response.headers.wont_be_nil
    end


    validate_response 'parameters are valid' do
      service = Aviator::Service.new(
        provider: 'openstack',
        service:  'compute',
        default_session_data: new_session_data
      )

      response = service.request :list_servers do |params|
        params[:details] = true
        params[:image] = 'c95d4992-24b1-4c9a-93cb-5d2935503148'
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:servers].length.must_equal 1
      response.headers.wont_be_nil
    end

    validate_response 'the all_tenants parameter is provided' do
      current_tenant = admin_session.send(:auth_info)[:access][:token][:tenant]

      response = admin_session.compute_service.request :list_servers do |params|
        params[:details]     = true
        params[:all_tenants] = true
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:servers].find{|s| s[:tenant_id] != current_tenant[:id] }.wont_be_empty
      response.headers.wont_be_nil
    end

  end

end