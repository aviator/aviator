require 'test_helper'

class Aviator::Test

  describe 'aviator/core/service' do
    
    def klass
      Aviator::Service
    end
    
    describe '#request' do
      
      def valid_params
        {
          username: Aviator::Test::Environment.admin[:username],
          password: Aviator::Test::Environment.admin[:password]
        }
      end

      
      def valid_request(params)
        service = klass.new(
                    provider: 'openstack',
                    service:  'identity',
                    access_details: {
                      bootstrap: {
                        url: Aviator::Test::Environment.admin[:auth_url]
                      }
                    }
                  )
        
        service.request :create_token, params
      end

            
      it 'knows how to use the bootstrap access_details' do
        response = valid_request(valid_params)
        
        response.status.must_equal 200
      end
      
      
      it 'returns an Aviator::Response object' do
        response = valid_request(valid_params)

        response.must_be_instance_of Aviator::Response
      end
      
      
      it 'returns the created Aviator::Request object' do
        params   = valid_params
        response = valid_request(params)

        params.each do |key, value|
          response.request.params.keys.must_include key
          response.request.params[key].must_equal params[key]
        end
      end
      
    end
    
  end

end