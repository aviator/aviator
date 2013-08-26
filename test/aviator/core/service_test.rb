require 'test_helper'

class Aviator::Test::Service < Aviator::Test::Base

  describe 'Aviator::Service' do
    
    def klass
      Aviator::Service
    end
    
    describe '#request' do
            
      it 'knows how to use the bootstrap access_details' do
        service = klass.new(
                    provider: 'openstack',
                    service:  'identity',
                    access_details: {
                      bootstrap: {
                        url: Aviator::Test::Environment.admin[:auth_url]
                      }
                    }
                  )
        
        response = service.request(:create_token) do
          {
            username: Aviator::Test::Environment.admin[:username],
            password: Aviator::Test::Environment.admin[:password]
          }
        end
        
        response.status.must_equal 200
      end
      
      
      it 'returns an Aviator::Response object' do
        service = klass.new(
                    provider: 'openstack',
                    service:  'identity',
                    access_details: {
                      bootstrap: {
                        url: Aviator::Test::Environment.admin[:auth_url]
                      }
                    }
                  )
        
        response = service.request(:create_token) do
          {
            username: Aviator::Test::Environment.admin[:username],
            password: Aviator::Test::Environment.admin[:password] 
          }
        end

        response.must_be_instance_of Aviator::Response
      end
      
    end
    
  end

end