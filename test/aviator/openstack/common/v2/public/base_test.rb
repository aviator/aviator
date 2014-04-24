require_relative '../../../../../test_helper'

class Aviator::Test

  describe 'aviator/openstack/common/v2/public/base' do

    def create_request(session_data = get_session_data, &block)
      block ||= lambda do |params|
                  params[:tenant_id] = 0
                  params[:role_id]   = 0
                  params[:user_id]   = 0
                end

      klass.new(session_data, &block)
    end


    def get_session_data
      session.send :auth_info
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'common', 'v2', 'public', 'base.rb')
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


    validate_attr :anonymous? do
      klass.anonymous?.must_equal false
    end


    validate_attr :api_version do
      klass.api_version.must_equal :v2
    end


    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :public
    end


    validate_attr :headers do
      headers = { 'X-Auth-Token' => get_session_data.token }

      request = create_request

      request.headers.must_equal headers
    end


    describe '::base_url' do

      it 'must throw a MissingServiceEndpointError when the service\'s endpoint can\'t be found' do
        default_session_data = Aviator::SessionData.from_body_and_headers(JSON.parse('{"access": {"token": {"issued_at": "2013-09-25T20:21:55.453783",
          "expires": "2013-09-26T02:21:55Z", "id": "2f6bdec6cd0f49b4a60ede0cd4bf2c0d"},
          "serviceCatalog": [], "user": {"username": "bogus",
          "roles_links": [], "id": "447527294dae4a1788d36beb0db99c00", "roles": [],
          "name": "bogus"}, "metadata": {"is_admin": 0, "roles":
          []}}}').with_indifferent_access, {})

        request = klass.new(default_session_data)

        the_method = lambda { request.send(:base_url) }

        the_method.must_raise Aviator::Service::MissingServiceEndpointError
      end


      it 'must use the base_url value if provided.' do
        default_session_data = Aviator::SessionData.from_body_and_headers JSON.parse('{"access": {"token": {"issued_at": "2013-09-25T20:21:55.453783",
          "expires": "2013-09-26T02:21:55Z", "id": "2f6bdec6cd0f49b4a60ede0cd4bf2c0d"},
          "serviceCatalog": [], "user": {"username": "bogus",
          "roles_links": [], "id": "447527294dae4a1788d36beb0db99c00", "roles": [],
          "name": "bogus"}, "metadata": {"is_admin": 0, "roles":
          []}}}').with_indifferent_access

        base_url = 'http://sample'

        default_session_data.merge!({ base_url: base_url })

        request = klass.new(default_session_data)

        request.send(:base_url).must_equal base_url
      end

    end

  end

end
