require_relative('../../test_helper')

class Aviator::Test

  describe 'aviator/core/session' do

    def config
      Environment
    end


    def log_file_path
      Pathname.new(__FILE__).expand_path.join('..', '..', '..', '..', 'tmp', 'aviator.log')
    end


    def new_session
      Aviator::Session.new(
        config_file: config.path,
        environment: 'openstack_admin',
        log_file:    log_file_path
      )
    end

    describe '#authenticate' do

      it 'authenticates against the auth service indicated in the config file' do
        session = new_session

        session.authenticate

        session.authenticated?.must_equal true
      end


      it 'authenticates against the auth service using the credentials in the given block' do
        session     = new_session
        credentials = config.openstack_admin[:auth_credentials]

        session.authenticate do |c|
          c[:username] = credentials[:username]
          c[:password] = credentials[:password]
        end

        session.authenticated?.must_equal true
      end


      it 'raises an AuthenticationError when authentication fails' do
        session     = new_session
        credentials = config.openstack_admin[:auth_credentials]

        the_method = lambda do
          session.authenticate do |c|
            c[:username] = 'invalidusername'
            c[:password] = 'invalidpassword'
          end
        end

        the_method.must_raise Aviator::Session::AuthenticationError
      end


      it 'updates the session data of its service objects' do
        session = new_session
        session.authenticate

        keystone = session.identity_service

        session_data_1 = keystone.default_session_data

        session.authenticate

        session.identity_service.must_equal keystone

        new_token = session.identity_service.default_session_data.token
        new_token.wont_equal session_data_1.token
        keystone.default_session_data.token.must_equal new_token
      end

    end # describe '#authenticate'


    describe '#dump' do

      it 'serializes the session data for caching' do
        session = new_session
        session.authenticate

        str = session.dump

        expected = JSON.generate({
          environment: session.send(:environment),
          auth_info: session.send(:auth_info).with_indifferent_access
        })

        str.must_equal expected
      end

    end


    describe '#load' do

      it 'returns itself' do
        session = new_session
        session.authenticate

        str = session.dump
        session.load(str).must_equal session
      end


      it 'updates the session data of its service objects' do
        session1 = new_session
        session1.authenticate
        keystone1 = session1.identity_service

        session2 = new_session
        session2.authenticate
        keystone2 = session2.identity_service

        session1.load(session2.dump)

        keystone1.wont_equal keystone2
        keystone1.default_session_data.must_equal keystone2.default_session_data
      end

    end # describe '#load'


    describe '::load' do

      it 'creates a new instance from the given session dump' do
        session = new_session
        session.authenticate

        str      = session.dump
        session  = Aviator::Session.load(str)
        expected = JSON.parse(str).with_indifferent_access

        session.dump.must_equal str
        session.authenticated?.must_equal true

        # This is bad testing practice (testing a private method) but
        # I'll go ahead and do it anyway just to be sure.
        session.send(:environment).must_equal expected[:environment]
        session.send(:auth_info).token.must_equal   Aviator::SessionData.from_hash(expected[:auth_info]).token
      end


      it 'uses the loaded auth info for its services' do
        session = new_session
        session.authenticate

        expected = JSON.parse(session.dump).with_indifferent_access
        session  = Aviator::Session.load(session.dump)
        service  = session.identity_service

        service.default_session_data.must_equal Aviator::SessionData.from_hash(expected[:auth_info])
      end

    end


    describe '::new' do

      it 'directs log entries to the given log file' do
        log_file_path.delete if log_file_path.file?

        session = new_session
        session.authenticate

        log_file_path.file?.must_equal true
      end

    end


    describe '#validate' do

      it 'returns true if session is still valid' do
        session = new_session
        session.authenticate

        session.validate.must_equal true
      end


      it 'returns false if session is no longer valid' do
        session = new_session
        session.authenticate

        session.send(:auth_info).token = 'invalidtokenid'

        session.validate.must_equal false
      end


      it 'raises an error if called before authenticating' do
        the_method = lambda { new_session.validate }

        the_method.must_raise Aviator::Session::NotAuthenticatedError
      end


      it 'returns true even when a default token is used' do
        session = new_session
        credentials = config.openstack_admin[:auth_credentials]

        session.authenticate do |c|
          c[:username] = credentials[:username]
          c[:password] = credentials[:password]
        end

        session.validate.must_equal true
      end

    end


    describe '#xxx_service' do

      it 'raises a NotAuthenticatedError if called without authenticating first' do
        the_method = lambda { new_session.identity_service }

        the_method.must_raise Aviator::Session::NotAuthenticatedError
      end


      it 'returns an instance of the indicated service' do
        session = new_session
        session.authenticate

        session.identity_service.wont_be_nil
      end

    end

  end # describe 'aviator/core/service'

end # class Aviator::Test