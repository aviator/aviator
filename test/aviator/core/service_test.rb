require 'test_helper'

class Aviator::Test

  describe 'aviator/core/service' do
    
    def klass
      Aviator::Service
    end
    
    describe '#request' do
      
      def valid_params
        lambda { |params|
          params.username = Aviator::Test::Environment.admin[:username]
          params.password = Aviator::Test::Environment.admin[:password]
        }
      end

      
      def valid_request
        service = klass.new(
                    provider: 'openstack',
                    service:  'identity',
                    access_details: {
                      bootstrap: {
                        url: Aviator::Test::Environment.admin[:auth_url]
                      }
                    }
                  )
        
        service.request :create_token, &valid_params
      end

            
      it 'knows how to use the bootstrap access_details' do
        response = valid_request
        
        response.status.must_equal 200
      end
      
      
      it 'returns an Aviator::Response object' do
        response = valid_request

        response.must_be_instance_of Aviator::Response
      end
      
      
      # it 'returns the created Aviator::Request object' do
      #   params   = valid_params.call(Struct.new)
      #   response = valid_request
      # 
      #   params.each do |key, value|
      #     response.request.params.keys.must_include key
      #     response.request.params[key].must_equal params[key]
      #   end
      # end
      
    end
    
  end

end