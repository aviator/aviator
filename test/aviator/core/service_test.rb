require_relative('../../test_helper')

class Aviator::Test

  describe 'aviator/core/service' do

    def config
      Environment.openstack_admin
    end


    def do_auth_request
      request_name = config[:auth_service][:request].to_sym

      bootstrap = {
        auth_service: config[:auth_service]
      }

      service.request request_name, session_data: bootstrap do |params|
        config[:auth_credentials].each do |k,v|
          params[k] = v
        end
      end
    end


    def klass
      Aviator::Service
    end


    def service(default_session_data=nil)
      options = {
        provider: config[:provider],
        service:  config[:auth_service][:name]
      }

      options[:default_session_data] = default_session_data unless default_session_data.nil?

      klass.new(options)
    end


    describe '#request' do

      it 'can find the correct request based on bootstrapped session data' do
        response = do_auth_request

        response.must_be_instance_of Aviator::Response
        response.request.api_version.must_equal config[:auth_service][:api_version].to_sym
      end


      it 'can find the correct request if api version is not defined but can be inferred from host_uri' do
        request_name = config[:auth_service][:request].to_sym

        bootstrap = {
          auth_service: {
            name:        'identity',
            host_uri:    'http://devstack:5000/v2.0',
            request:     'create_token'
          }
        }

        response = service.request request_name, session_data: bootstrap do |params|
          config[:auth_credentials].each do |k,v|
            params[k] = v
          end
        end

        response.must_be_instance_of Aviator::Response
        response.request.api_version.must_equal :v2
        response.status.must_equal 200
      end


      it 'raises an error if session data does not have the endpoint information' do
        request_name = config[:auth_service][:request].to_sym

        bootstrap = Aviator::SessionData.from_body JSON.parse('{"access": {"token": {"issued_at": "2013-09-25T20:21:55.453783",
          "expires": "2013-09-26T02:21:55Z", "id": "2f6bdec6cd0f49b4a60ede0cd4bf2c0d"},
          "serviceCatalog": [], "user": {"username": "bogus",
          "roles_links": [], "id": "447527294dae4a1788d36beb0db99c00", "roles": [],
          "name": "bogus"}, "metadata": {"is_admin": 0, "roles":
          []}}}').with_indifferent_access

        s = service(bootstrap)

        the_method = lambda { s.request request_name }

        the_method.must_raise Aviator::Service::MissingServiceEndpointError
      end


      it 'can find the correct request based on non-bootstrapped session data' do
        session_data = Aviator::SessionData.from_response do_auth_request

        response = service.request :list_tenants, session_data: session_data

        response.status.must_equal 200
      end


      it 'uses the default session data if session data is not provided' do
        default_session_data = Aviator::SessionData.from_response do_auth_request
        s = service(default_session_data)

        response = s.request :list_tenants

        response.status.must_equal 200
      end


      it 'raises a SessionDataNotProvidedError if there is no session data' do
        the_method = lambda do
          service.request :list_tenants
        end

        the_method.must_raise Aviator::Service::SessionDataNotProvidedError
        error = the_method.call rescue $!
        error.message.wont_be_nil
      end


      it 'accepts an endpoint type option for selecting a specific request' do
        default_session_data = Aviator::SessionData.from_response do_auth_request
        s = service(default_session_data)

        response1 = s.request :list_tenants, endpoint_type: 'admin'
        response2 = s.request :list_tenants, endpoint_type: 'public'

        response1.request.url.wont_equal response2.request.url
      end

    end


    describe '#request_classes' do

      it 'returns an array of the request classes' do
        provider_name = config[:provider]
        service_name  = config[:auth_service][:name]
        service_path  = Pathname.new(__FILE__).join(
                          '..', '..', '..', '..', 'lib', 'aviator', provider_name, service_name
                        ).expand_path

        request_files = Pathname.glob(service_path.join('**', '*.rb'))
                          .map{|rf| rf.to_s.match(/#{provider_name}\/#{service_name}\/([\w\/]+)\.rb$/) }
                          .map{|rf| rf[1].split('/').map{|c| c.camelize }.join('::') }

        classes = request_files.map do |rf|
          "Aviator::#{provider_name.camelize}::#{service_name.camelize}::#{rf}".constantize
        end

        service.request_classes.must_equal classes
      end

    end


    describe '#default_session_data=' do

      it 'sets the service\'s default session data' do
        bootstrap = {
          auth_service: {
            name:     'identity',
            host_uri: 'http://devstack:5000/v2.0',
            request:  'create_token'
          }
        }

        svc = service(bootstrap)

        session_data_1 = svc.default_session_data
        session_data_2 = do_auth_request.body

        svc.default_session_data = session_data_2

        svc.default_session_data.wont_equal session_data_1
        svc.default_session_data.must_equal session_data_2
      end

    end

  end

end