require 'test_helper'

class Aviator::Test::Service < Aviator::Test::Base

  describe 'Aviator::Service' do
    
    def klass
      Aviator::Service
    end
    
    describe '#request' do
      
      it 'knows how to use the bootstrap access_details' do
        service = klass.new(
                    service_name: 'identity_service',
                    access_details: {
                      bootstrap: {
                        url: Aviator::Test::Environment.admin[:auth_url]
                      }
                    }
                  )
        
        response = service.request(:create_token) do |params|
          params[:username] = Aviator::Test::Environment.admin[:username]
          params[:password] = Aviator::Test::Environment.admin[:password]
        end
        
        response.must_respond_to :status
        response.must_respond_to :body
        response.must_respond_to :headers
      end
      
    end
    
  end

end