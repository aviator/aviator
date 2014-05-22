require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/identity/v3/public/list_domains' do

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

    validate_response 'parameters are valid' do
      service   = session.identity_service
      response  = service.request :list_domains, :version => :v3

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:domains].wont_be_nil
      response.headers.wont_be_nil
    end

  end

end