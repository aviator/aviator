require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/provider' do

    def config
      Environment.openstack_admin
    end


    def do_auth_request(api_version=:v2)
      request_name = config[:auth_service][:request].to_sym

      bootstrap = {
        :auth_service => config[:auth_service].dup
      }

      bootstrap[:auth_service][:api_version] = api_version

      response = load_service.request request_name, :session_data => bootstrap do |params|
        config[:auth_credentials].each do |k,v|
          params[k] = v
        end

        if api_version == :v3
          params[:domain_id] = "default"
        end
      end

      Hashish.new({
        :body    => response.body,
        :headers => response.headers
      })
    end


    def load_service(service=nil, default_session_data=nil)
      options = {
        :provider => config[:provider],
        :service  => service ? service.to_s : config[:auth_service][:name]
      }

      options[:default_session_data] = default_session_data unless default_session_data.nil?

      Aviator::Service.new(options)
    end


    def modyul
      Aviator::Openstack::Provider
    end


    describe '#find_request' do

      it 'can find the correct request class if api version is not defined but can be inferred from host_uri' do
        load_service

        bootstrap = {
          :auth_service => {
            :name        => 'identity',
            :host_uri    => 'http://devstack:5000/v2.0',
            :request     => 'create_token'
          }
        }

        request_class = modyul.find_request(
                            bootstrap[:auth_service][:name],
                            bootstrap[:auth_service][:request],
                            bootstrap,
                            {}
                        )
        api_version = bootstrap[:auth_service][:host_uri].match(/(v\d+)\.?\d*/)[1].to_sym

        request_class.api_version.must_equal api_version
      end


      it 'can find the correct request class if based on the provided version' do
        load_service

        bootstrap = {
          :auth_service => {
            :name        => 'identity',
            :host_uri    => 'http://devstack:5000',
            :request     => 'create_token'
          }
        }
        api_version = :v2
        request_class = modyul.find_request(
                            bootstrap[:auth_service][:name],
                            bootstrap[:auth_service][:request],
                            bootstrap,
                            { :api_version => api_version }
                        )

        request_class.wont_be_nil
        request_class.api_version.must_equal api_version
      end


      it 'raises an error if session data does not have the endpoint information' do
        load_service
        request_name = config[:auth_service][:request].to_sym

        bootstrap = Hashish.new({ :body => JSON.parse('{"access": {"token": {"issued_at": "2013-09-25T20:21:55.453783",
                  "expires": "2013-09-26T02:21:55Z", "id": "2f6bdec6cd0f49b4a60ede0cd4bf2c0d"},
                  "serviceCatalog": [], "user": {"username": "bogus",
                  "roles_links": [], "id": "447527294dae4a1788d36beb0db99c00", "roles": [],
                  "name": "bogus"}, "metadata": {"is_admin": 0, "roles":
                  []}}}')})

        the_method = lambda { modyul.find_request('identity', request_name, bootstrap, {}) }

        the_method.must_raise Aviator::Service::MissingServiceEndpointError
      end


      it 'v2: can find the correct request based on non-bootstrapped session data' do
        session_data = do_auth_request
        service_name = :identity
        request_name = :list_tenants
        service_spec = session_data[:body][:access][:serviceCatalog].find{|s| s[:type] == service_name.to_s }
        version = service_spec[:endpoints][0][:publicURL].match(/(v\d+)\.?\d*/)[1].to_sym

        request = modyul.find_request(service_name, request_name, session_data, {})

        request.service.must_equal service_name
        request.api_version.must_equal version
      end


      it 'v3: can find the correct request based on non-bootstrapped session data' do
        session_data = do_auth_request(:v3)
        service_name = :identity
        request_name = :list_tenants
        service_obj  = load_service(service_name)
        # Delete all other service endpoints to ensure test repeatability
        session_data[:body][:token][:catalog].delete_if{|s| s['type'] != service_name.to_s }
        service_spec = session_data[:body][:token][:catalog].find{|s| s['type'] == service_name.to_s }
        version = service_spec[:endpoints][0][:url].match(/(v\d+)\.?\d*/)[1].to_sym

        request = modyul.find_request(service_name, request_name, session_data, {})

        request.wont_be_nil
        request.service.must_equal service_name
        request.api_version.must_equal version
      end

      it 'v3: can find the correct request based on non-bootstrapped data (suffixed)' do
        session_data = do_auth_request(:v3)
        service_name = :identity
        request_name = :list_tenants
        service_obj  = load_service(service_name)
        # Delete all other service endpoints to ensure test repeatability
        session_data[:body][:token][:catalog].delete_if{|s| s['type'] != service_name.to_s }
        # Add a prefix to the service type
        suffix = "v999"
        session_data[:body][:token][:catalog].each{|s| s['type'] = "#{ service_name }#{ suffix }" }
        service_spec = session_data[:body][:token][:catalog].find{|s| s['type'] == "#{ service_name }#{ suffix }" }
        version = service_spec[:endpoints][0][:url].match(/(v\d+)\.?\d*/)[1].to_sym

        request = modyul.find_request(service_name, request_name, session_data, {})

        request.wont_be_nil
        request.service.must_equal service_name
        request.api_version.must_equal version
      end

      it 'v2: throws an error if there is more than one service info found' do
        session_data = do_auth_request(:v2)
        service_name = :identity
        request_name = :list_tenants
        service_obj  = load_service(service_name)
        # Modify service types to be all the same
        session_data[:body][:access][:serviceCatalog].each_with_index{|s,i| s['type'] = "#{ service_name }v#{ i }" }

        the_method = lambda { modyul.find_request(service_name, request_name, session_data, {}) }

        the_method.must_raise Aviator::Openstack::Provider::MultipleServiceApisError
      end

      it 'v3: throws an error if there is more than one service info found' do
        session_data = do_auth_request(:v3)
        service_name = :identity
        request_name = :list_tenants
        service_obj  = load_service(service_name)
        # Modify service types to be all the same
        session_data[:body][:token][:catalog].each_with_index{|s,i| s['type'] = "#{ service_name }v#{ i }" }

        the_method = lambda { modyul.find_request(service_name, request_name, session_data, {}) }

        the_method.must_raise Aviator::Openstack::Provider::MultipleServiceApisError
      end

      it 'accepts an endpoint type option for selecting a specific request' do
        load_service

        bootstrap = {
          :auth_service => config[:auth_service]
        }

        request1 = modyul.find_request(
                       :identity,
                       :list_tenants,
                       bootstrap,
                       { :endpoint_type => :admin }
                   )
        request2 = modyul.find_request(
                       :identity,
                       :list_tenants,
                       bootstrap,
                       { :endpoint_type => :public }
                   )

        request1.wont_be_nil
        request2.wont_be_nil
        request1.wont_equal request2
      end

    end

  end

end
