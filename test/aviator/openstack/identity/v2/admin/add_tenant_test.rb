require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/identity/v2/admin/add_tenant' do
    
    def klass
      Aviator::Service
    end


    def do_auth_request
      config = Environment.admin

      service = klass.new(
        provider: config[:provider],
        service:  config[:auth_service][:name]
      )

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
    
    
    def service
      klass.new(
        provider: 'openstack',
        service:  'identity'
      )
    end


    describe '#request' do
            
      it 'knows how to extract and use the session data' do
        session_data = do_auth_request.body
        
        response = service.request :add_tenant, session_data do |params|
          params.name        = 'Test Project'
          params.description = 'This is a test'
          params.enabled     =  true
        end
        
        response.status.must_equal 200
      end
      
    end
    
  end

end