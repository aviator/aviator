require_relative('../../../../../test_helper')

class Aviator::Test

  describe 'aviator/openstack/identity/v3/public/get_projects_by_user_id' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |params|
        params.id = get_session_id
      end

      klass.new(session_data, &block)
    end


    def get_session_data
      session.send :auth_info
    end

    def get_session_id
      get_session_data[:access][:user][:id]
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'identity', 'v3', 'public', 'get_projects_by_user_id.rb')
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
      klass.api_version.must_equal :v3
    end


    validate_attr :body do
      klass.body?.must_equal false
      create_request.body?.must_equal false
    end


    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :public
    end


    validate_attr :headers do
      session_data = get_session_data

      headers = { 'X-Auth-Token' => session_data[:access][:token][:id] }

      request = create_request(session_data)

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :get
    end


    validate_attr :url do
      session_data = get_session_data
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'identity' }
      url          = "#{ service_spec[:endpoints][0][:publicURL] }/users/#{get_session_id}/projects"
      request      = create_request(session_data)

      request.url.must_equal url
    end

    validate_attr :required_params do
      klass.required_params.must_equal [:id]
    end

    validate_response 'session is using a default token and passes correct id' do
      s = Aviator::Session.new(
          config_file: Environment.path,
          environment: 'openstack_admin'
        )

      s.authenticate do |creds|
        creds.username = Environment.openstack_admin[:auth_credentials][:username]
        creds.password = Environment.openstack_admin[:auth_credentials][:password]
      end
      auth_info = session.send :auth_info
      id = auth_info[:access][:user][:id]
      base_url = URI(Environment.openstack_admin[:auth_service][:host_uri])
      base_url.path = "/v3"

      # base_url should have the form 'https://<domain>:<port>/<api_version>'
      response = s.identity_service.request :get_projects_by_user_id, endpoint_type: :public, base_url: base_url.to_s do |p|
        p.id = id
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:projects].length.wont_equal 0
      response.headers.wont_be_nil
    end


  end

end
