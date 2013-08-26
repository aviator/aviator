require 'test_helper'

class Aviator::Test

  describe 'aviator/core/service' do

    def config
      Environment.admin
    end
    
    def klass
      Aviator::Service
    end

    def service
      klass.new(
        provider: config[:provider],
        service:  config[:auth_service][:name]
      )
    end

    describe '#request' do

      def do_auth_request
        request_name = config[:auth_service][:request].to_sym

        bootstrap = {
          auth_service: config[:auth_service]
        }

        service.request request_name, bootstrap do |params|
          config[:auth_credentials].each do |k,v|
            params[k] = v
          end
        end
      end


      it 'can find the correct request based on bootstrapped session data' do
        response = do_auth_request

        response.must_be_instance_of Aviator::Response
        response.request.api_version.must_equal config[:auth_service][:api_version].to_sym
      end
      
      
      it 'can find the correct request based on non-bootstrapped session data' do
        session_data = do_auth_request.body
        
        response = service.request :create_tenant, session_data do |params|
          params.name        = 'Test Project'
          params.description = 'This is a test'
          params.enabled     =  true
        end
        
        response.status.must_equal 200
      end

    end

  end

end