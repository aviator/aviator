require 'test_helper'

class Aviator::Test

  describe 'aviator/core/session' do

    def config
      Environment
    end


    def new_session
      Aviator::Session.new(
        config_file: config.path,
        environment: 'test'
      )
    end


    def log_file_path
      Pathname.new(__FILE__).expand_path.join('..', '..', '..', '..', 'tmp', 'aviator.log')
    end


    describe '#authenticate' do      

      it 'authenticates against the auth service indicated in the config file' do
        session = new_session
        
        session.authenticate

        session.authenticated?.must_equal true
      end
            
            
      it 'authenticates against the auth service using the credentials in the given block' do
        session     = new_session
        credentials = config.test[:auth_credentials]
        
        session.authenticate do |c|
          c[:username] = credentials[:username]
          c[:password] = credentials[:password]
        end
        
        session.authenticated?.must_equal true
      end

    end # describe '#authenticate'
    
    
    describe '#xxx_service' do
      
      it 'returns an instance of the indicated service' do
        session = new_session
        session.authenticate
        
        session.identity_service.wont_be_nil
      end
      
    end

  end # describe 'aviator/core/service'

end # class Aviator::Test