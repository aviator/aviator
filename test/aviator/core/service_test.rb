require 'test_helper'

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
      
      
      it 'can find the correct request based on non-bootstrapped session data' do
        session_data = do_auth_request.body
        
        response = service.request :create_tenant, session_data: session_data do |params|
          params.name        = 'Test Project'
          params.description = 'This is a test'
          params.enabled     =  true
        end
        
        response.status.must_equal 200
      end
      
      
      it 'uses the default session data if session data is not provided' do
        default_session_data = do_auth_request.body
        s = service(default_session_data)

        response = s.request :create_tenant do |params|
          params.name        = 'Test Project Too'
          params.description = 'This is a test'
          params.enabled     =  true
        end
        
        response.status.must_equal 200
      end
      
      
      it 'raises a SessionDataNotProvidedError if there is no session data' do
        the_method = lambda do
          service.request :create_tenant do |params|
            params.name        = 'Test Project Too'
            params.description = 'This is a test'
            params.enabled     =  true
          end
        end
        
        the_method.must_raise Aviator::Service::SessionDataNotProvidedError
        error = the_method.call rescue $!
        error.message.wont_be_nil
      end
      
      
      it 'accepts an endpoint type option for selecting a specific request' do
        default_session_data = do_auth_request.body
        s = service(default_session_data)

        response1 = s.request :list_tenants, endpoint_type: 'admin'
        response2 = s.request :list_tenants, endpoint_type: 'public'
        
        response1.request.url.wont_equal response2.request.url
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