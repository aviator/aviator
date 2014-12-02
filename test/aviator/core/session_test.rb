require 'test_helper'
require 'mocha/setup'

require 'support/dummy/provider'


describe 'Aviator::Session' do

  # Methods/attributes shared across tests

  def stub_body
    '{"key":"value"}'
  end


  def stub_headers
    {}
  end


  def stub_http
    mock_conn = mock('Faraday::Connection')
    mock_http_req = mock('Faraday::Request')
    mock_response = mock('Faraday::Response')
    Faraday.expects(:new).returns(mock_conn)
    mock_conn.stubs(:post).yields(mock_http_req).returns(mock_response)
    mock_http_req.stubs(:url)
    mock_http_req.stubs(:body=)
    mock_response.stubs(:status).returns(200)
    mock_response.stubs(:headers).returns(stub_headers)
    mock_response.stubs(:body).returns(stub_body)
  end


  def valid_config
    @valid_config ||= YAML::load <<-YAML
      production:
        provider: dummy
        auth_service:
          name:      auth
          host_uri:  http://some.address.com
          request:   authenticate
          validator: validate
        auth_credentials:
          username:    myusername
          password:    mypassword
      YAML
  end


  def valid_config_path
    'path/to/config.yml'
  end


  def valid_env
    @valid_env ||= valid_config.keys.first
  end


  # Tests/expectations

  describe '#authenticate' do

    it 'authenticates against the auth service declared in its config' do
      mock_conn = mock('Faraday::Connection')
      mock_http_req = mock('Faraday::Request')
      mock_response = mock('Faraday::Response')
      Faraday.expects(:new).returns(mock_conn)
      mock_conn.expects(:post).yields(mock_http_req).returns(mock_response)
      mock_http_req.expects(:url)
      mock_http_req.expects(:body=).with(){|json| JSON.load(json) == valid_config[valid_env]['auth_credentials']}
      mock_response.expects(:status).returns(200)
      mock_response.expects(:headers).returns({})
      mock_response.expects(:body).returns({})

      session = Aviator::Session.new(:config => valid_config[valid_env])
      session.authenticate

      session.authenticated?.must_equal true
    end


    it 'authenticates against the auth service using the credentials in the given block' do
      # Keys below are dependent on whatever is declared in
      # the request classes referenced by auth_service:request
      # in the config file
      params = {
        'username' => 'someuser',
        'password' => 'password'
      }

      mock_conn = mock('Faraday::Connection')
      mock_http_req = mock('Faraday::Request')
      mock_response = mock('Faraday::Response')
      Faraday.expects(:new).returns(mock_conn)
      mock_conn.expects(:post).yields(mock_http_req).returns(mock_response)
      mock_http_req.expects(:url)
      mock_http_req.expects(:body=).with(){|json| JSON.load(json) == params }
      mock_response.expects(:status).returns(200)
      mock_response.expects(:headers).returns({})
      mock_response.expects(:body).returns({})

      session = Aviator::Session.new(:config => valid_config[valid_env])
      session.authenticate do |p|
        params.each do |key, value|
          p[key] = value
        end
      end

      session.authenticated?.must_equal true
    end


    it 'raises an AuthenticationError when authentication fails' do
      Faraday.expects(:new).returns(mock_conn = mock('Faraday::Connection'))
      mock_conn.expects(:post).returns(mock_response = mock('Faraday::Response'))
      mock_response.expects(:status).returns(401)
      mock_response.expects(:body).returns({})

      session = Aviator::Session.new(:config => valid_config[valid_env])
      # Wrapping the next method call in a lambda so that we can
      # check if an AuthenticationError was raised. See assertion.
      auth_method = lambda do
        session.authenticate do |c|
          c[:username] = 'invalidusername'
          c[:password] = 'invalidpassword'
        end
      end

      auth_method.must_raise Aviator::Session::AuthenticationError
    end


    it 'updates the session data of its service objects' do
      # This test ensures that Session will always update the session
      # data in Service objects that were created before reauthentication
      mock_conn = mock('Faraday::Connection')
      mock_http_req = mock('Faraday::Request')
      mock_response_1 = mock('Faraday::Response')
      mock_response_2 = mock('Faraday::Response')
      Faraday.expects(:new).returns(mock_conn)
      mock_conn.stubs(:post).yields(mock_http_req).returns(mock_response_1, mock_response_2)
      mock_http_req.stubs(:url)
      mock_http_req.stubs(:body=)
      mock_response_1.stubs(:status).returns(200)
      mock_response_1.stubs(:headers).returns({})
      mock_response_1.stubs(:body).returns('{"session_data":1}')
      mock_response_2.stubs(:status).returns(200)
      mock_response_2.stubs(:headers).returns({})
      mock_response_2.stubs(:body).returns('{"session_data":2}')

      # First authentication
      session = Aviator::Session.new(:config => valid_config[valid_env])
      session.authenticate
      session.authenticated?.must_equal true

      # Capture session data
      auth_service   = session.auth_service
      session_data_1 = auth_service.default_session_data

      # Second authentication
      session.authenticate
      session.authenticated?.must_equal true

      # Check second session data
      session.auth_service.must_equal auth_service
      auth_service.default_session_data.wont_equal session_data_1
    end

  end


  describe '#dump' do

    it 'serializes the session data for caching' do
      stub_http

      session = Aviator::Session.new(:config => valid_config[valid_env])
      session.authenticate
      session.authenticated?.must_equal true

      expected = JSON.generate({
        :config        => valid_config[valid_env],
        :auth_response => Hashish.new({ :headers => stub_headers, :body => JSON.load(stub_body) })
      })

      # Convert back to json since key ordering is not preserved in Ruby 1.8
      JSON.load(session.dump).must_equal JSON.load(expected)
    end

  end


  describe '#load' do

    it 'returns itself' do
      stub_http

      session = Aviator::Session.new(:config => valid_config[valid_env])
      session.authenticate

      session.authenticated?.must_equal true
      session.load(session.dump).must_equal session
    end


    it 'updates the session data of its service objects' do
      # This test ensures that Session will always update the session
      # data in Service objects that were created before reload
      mock_conn = mock('Faraday::Connection')
      mock_http_req = mock('Faraday::Request')
      mock_response_1 = mock('Faraday::Response')
      mock_response_2 = mock('Faraday::Response')
      Faraday.stubs(:new).returns(mock_conn)
      mock_conn.stubs(:post).yields(mock_http_req).returns(mock_response_1, mock_response_2)
      mock_http_req.stubs(:url)
      mock_http_req.stubs(:body=)
      mock_response_1.stubs(:status).returns(200)
      mock_response_1.stubs(:headers).returns({})
      mock_response_1.stubs(:body).returns('{"session_data":1}')
      mock_response_2.stubs(:status).returns(200)
      mock_response_2.stubs(:headers).returns({})
      mock_response_2.stubs(:body).returns('{"session_data":2}')

      # First session
      session1 = Aviator::Session.new(:config => valid_config[valid_env])
      session1.authenticate
      session1.authenticated?.must_equal true
      auth_service_1 = session1.auth_service

      # Second session
      session2 = Aviator::Session.new(:config => valid_config[valid_env])
      session2.authenticate
      session2.authenticated?.must_equal true
      auth_service_2 = session2.auth_service

      session1.load(session2.dump)

      session1.wont_equal session2
      session1.auth_service.wont_equal session2.auth_service
      auth_service_1.default_session_data.must_equal auth_service_2.default_session_data
    end

  end


  describe '::load' do

    it 'creates a new instance from the given session dump' do
      stub_http

      session1 = Aviator::Session.new(:config => valid_config[valid_env])
      session1.authenticate
      session1.authenticated?.must_equal true
      auth_service_1 = session1.auth_service

      session2 = Aviator::Session.load(session1.dump)
      session2.authenticated?.must_equal true
      auth_service_2 = session2.auth_service

      session1.wont_equal session2
      session1.auth_service.wont_equal session2.auth_service
      auth_service_1.default_session_data.must_equal auth_service_2.default_session_data
    end

  end


  describe '::new' do

    it 'accepts a config file and environment name' do
      Pathname.any_instance.stubs(:file?).returns(true)
      YAML.expects(:load_file).with(valid_config_path).returns(valid_config)

      session = Aviator::Session.new(:config_file => valid_config_path,
                                     :environment => valid_env)

      session.config.must_equal Hashish.new(valid_config[valid_env])
    end


    it 'accepts a hash object as configuration' do
      hash = valid_config[valid_env]

      session = Aviator::Session.new(:config => hash)

      session.config.must_equal Hashish.new(hash)
    end


    it 'accepts a session dump' do
      mock_conn = mock('Faraday::Connection')
      mock_http_req = mock('Faraday::Request')
      mock_response = mock('Faraday::Response')
      Faraday.expects(:new).returns(mock_conn)
      mock_conn.stubs(:post).yields(mock_http_req).returns(mock_response)
      mock_http_req.stubs(:url)
      mock_http_req.stubs(:body=)
      mock_response.stubs(:status).returns(200)
      mock_response.stubs(:headers).returns({})
      mock_response.stubs(:body).returns('{"session_data":1}')

      session1 = Aviator::Session.new(:config => valid_config[valid_env])
      session1.authenticate
      session1.authenticated?.must_equal true

      session2 = Aviator::Session.new(:session_dump => session1.dump)

      session2.authenticated?.must_equal true
      session2.config.must_equal Hashish.new(valid_config[valid_env])
    end


    it 'optionally accepts a log file path' do
      hash = valid_config[valid_env]
      path = '/path/to/log/file.log'

      session = Aviator::Session.new(:config => hash, :log_file => path)

      session.log_file.must_equal path
    end


    it 'raises an error when required constructor keys are missing' do
      new_method = lambda { Aviator::Session.new(:log_file => '/path/to/log/file/log') }
      new_method.must_raise Aviator::Session::InitializationError

      error = new_method.call rescue $!

      error.message.wont_be_nil
    end

  end


  describe '#request' do

    it 'delegates to Service#request' do
      request_name   = :create_server
      request_opts   = {}
      request_params = lambda do |params|
                         params[:key1] = :value1
                         params[:key2] = :value2
                       end
      yielded_params = {}

      mock_auth     = mock('Aviator::Service')
      mock_compute  = mock('Aviator::Service')
      mock_response = mock('Aviator::Response')

      Aviator::Service.expects(:new).twice.returns(mock_auth, mock_compute)
      mock_response.stubs(:status).returns(200)
      mock_response.stubs(:headers).returns({})
      mock_response.stubs(:body).returns('{}')
      mock_auth.expects(:request).returns(mock_response)
      mock_compute.expects(:request).with(request_name, request_opts).yields(yielded_params).returns(mock_response)

      session = Aviator::Session.new(:config => valid_config[valid_env])
      session.authenticate

      session.request :compute, request_name, request_opts, &request_params
      yielded_params.wont_be_empty
    end

  end


  describe '#validate' do

    it 'returns true if session is still valid' do
      stub_http

      session = Aviator::Session.new(:config => valid_config[valid_env])
      session.authenticate

      session.validate.must_equal true
    end


    it 'returns false if session is no longer valid' do
      mock_conn = mock('Faraday::Connection')
      mock_http_req = mock('Faraday::Request')
      mock_response = mock('Faraday::Response')
      Faraday.expects(:new).returns(mock_conn)
      mock_conn.stubs(:post).yields(mock_http_req).returns(mock_response)
      mock_http_req.stubs(:url)
      mock_http_req.stubs(:body=)
      mock_response.stubs(:status).returns(200)
      mock_response.stubs(:headers).returns(stub_headers)
      mock_response.stubs(:body).returns(stub_body)

      session = Aviator::Session.new(:config => valid_config[valid_env])
      session.authenticate

      session.validate.must_equal true

      # Stub response status to 401 this time
      mock_response.stubs(:status).returns(401)

      session.validate.must_equal false
    end


    it 'raises an error if called before authenticating and no default session data is provided' do
      session = Aviator::Session.new(:config => valid_config[valid_env])

      the_method = lambda { session.validate }

      the_method.must_raise Aviator::Session::NotAuthenticatedError
    end

  end


  describe '#xxxxx_service' do

    it 'returns an instance of the indicated service' do
      stub_http

      session = Aviator::Session.new(:config => valid_config[valid_env])
      session.authenticate

      session.compute_service.wont_be_nil
    end

    it 'returns an instance of the indicated service even if not authenticated' do
      session = Aviator::Session.new(:config => valid_config[valid_env])

      session.authenticated?.must_equal false
      session.compute_service.wont_be_nil
    end

  end

end
