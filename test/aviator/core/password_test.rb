require_relative('../../test_helper')

class Aviator::Test

  describe 'aviator/core/password' do

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

    def session
      unless @session
        @session = Aviator::Session.new(
          config_file: Environment.path,
          environment: 'openstack_admin'
        )
        @session.authenticate
      end

      @session
    end


    before :each do
      system(%(> #{log_file_path}))
    end


    describe '#password' do

      it 'filters the valid passwords' do
        session     = new_session
        credentials = config.openstack_admin[:auth_credentials]

        session.authenticate do |c|
          c[:username] = credentials[:username]
          c[:password] = credentials[:password]
        end

        filtered = false

        if File.readlines(log_file_path).grep(/FILTERED_VALUE/).size > 0
          filtered=true
        end

        filtered.must_equal true
      end

      it 'filters special characters' do
        session     = new_session
        credentials = config.openstack_admin[:auth_credentials]

        session.authenticate do |c|
          c[:username] = 'invalidusername'
          c[:password] = 'm@!@#$%^&*'
        end

        filtered = false
        unfiltered = false

        if File.readlines(log_file_path).grep(/m@\!@#\$%\^\&\*/).size > 0
          unfiltered=true
        end

        if File.readlines(log_file_path).grep(/FILTERED_VALUE/).size > 0
          filtered=true
        end

        #special characters password must not be in aviator.log
        unfiltered.must_equal false

        #FILTERED_VALUE must be seen instead of the password
        filtered.must_equal true

      end

    end #password filter

  end # describe 'aviator/core/service'

end # class Aviator::Test