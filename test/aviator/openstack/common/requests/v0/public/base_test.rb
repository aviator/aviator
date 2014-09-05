require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/common/requests/v0/public/base' do

    def create_request(session_data=get_session_data, &block)
      klass.new(session_data)
    end


    def get_session_data(keystone_api_version=:v2)
      session(keystone_api_version).send :auth_response
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'common', 'v0', 'public', 'base.rb')
    end


    def session(api_version=:v2)
      unless @session
        config = Environment.openstack_admin.dup
        config[:auth_service][:api_version] = api_version.to_sym

        @session = Aviator::Session.new(
          :config => config
        )
        if api_version == :v2
          @session.authenticate
        elsif api_version == :v3
          @session.authenticate do |params|
            params[:username]  = Environment.openstack_admin[:auth_credentials][:username]
            params[:password]  = Environment.openstack_admin[:auth_credentials][:password]
            params[:domain_id] = "default"
          end
        else
          raise "Unsupported Keystone API version #{ api_version }"
        end
      end

      @session
    end


    validate_attr :anonymous? do
      klass.anonymous?.must_equal false
    end


    validate_attr :api_version do
      klass.api_version.must_equal :v0
    end


    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :public
    end


    describe '#headers' do

      it 'must know to extract a service token if provided' do
        session_data = {
          :base_url => 'http://example.com',
          :service_token => 'sometokenipickedupfromsomewhere'
        }
        headers = { 'X-Auth-Token' => session_data[:service_token] }

        request = create_request(session_data)

        request.headers.must_equal headers
      end


      it 'must know to extract token from a Keystone v2 auth info' do
        session_data = get_session_data(:v2)
        headers = { 'X-Auth-Token' => session_data[:body][:access][:token][:id] }

        request = create_request(session_data)

        request.headers.must_equal headers
      end


      it 'must know to extract token from a Keystone v3 auth info' do
        session_data = get_session_data(:v3)
        headers = { 'X-Auth-Token' => session_data[:headers]['x-subject-token'] }

        request = create_request(session_data)

        request.headers.must_equal headers
      end

    end


    describe '::base_url' do

      it 'must know how to extract the base url from a Keystone v2 session data' do
        session_data  = get_session_data(:v2)
        service       = :compute
        api_version   = :v2
        endpoint_type = :admin
        service_info  = session_data[:body][:access][:serviceCatalog].select{ |s| s[:type] == service.to_s }
        endpoints     = service_info.find{ |s| s.keys.include? "endpoints" }['endpoints']
        expected_url  = endpoints[0]["#{ endpoint_type }URL"]

        base_request  = klass
        child_request = Class.new(base_request) do
                          meta :service,       service
                          meta :api_version,   api_version
                          meta :endpoint_type, endpoint_type
                        end

        request = child_request.new(session_data)

        request.send(:base_url).must_equal expected_url
      end

      it 'must know how to extract the base url from a Keystone v3 session data' do
        session_data  = get_session_data(:v3)
        service       = :compute
        api_version   = :v3
        endpoint_type = :public
        service_info  = session_data[:body][:token][:catalog].select{ |s| s[:type] == "#{ service }#{ api_version }" }
        endpoints     = service_info.find{ |s| s.keys.include? "endpoints" }['endpoints']
        expected_url  = endpoints.find{ |s| s['interface'] == endpoint_type.to_s }['url']

        base_request  = klass
        child_request = Class.new(base_request) do
                          meta :service,       service
                          meta :api_version,   api_version
                          meta :endpoint_type, endpoint_type
                        end

        request = child_request.new(session_data)

        request.send(:base_url).must_equal expected_url
      end

      it 'must throw a MissingServiceEndpointError when the service\'s endpoint can\'t be found' do
        default_session_data = Hashish.new({ :body => JSON.parse('{"access": {"token": {"issued_at": "2013-09-25T20:21:55.453783",
                  "expires": "2013-09-26T02:21:55Z", "id": "2f6bdec6cd0f49b4a60ede0cd4bf2c0d"},
                  "serviceCatalog": [], "user": {"username": "bogus",
                  "roles_links": [], "id": "447527294dae4a1788d36beb0db99c00", "roles": [],
                  "name": "bogus"}, "metadata": {"is_admin": 0, "roles":
                  []}}}')})

        request = klass.new(default_session_data)

        the_method = lambda { request.send(:base_url) }

        the_method.must_raise Aviator::Service::MissingServiceEndpointError
      end


      it 'must use the base_url value if provided.' do
        default_session_data = Hashish.new({ :body => JSON.parse('{"access": {"token": {"issued_at": "2013-09-25T20:21:55.453783",
                  "expires": "2013-09-26T02:21:55Z", "id": "2f6bdec6cd0f49b4a60ede0cd4bf2c0d"},
                  "serviceCatalog": [], "user": {"username": "bogus",
                  "roles_links": [], "id": "447527294dae4a1788d36beb0db99c00", "roles": [],
                  "name": "bogus"}, "metadata": {"is_admin": 0, "roles":
                  []}}}')})

        base_url = 'http://sample'

        default_session_data.merge!({ :base_url => base_url })

        request = klass.new(default_session_data)

        request.send(:base_url).must_equal base_url
      end

    end

  end

end
