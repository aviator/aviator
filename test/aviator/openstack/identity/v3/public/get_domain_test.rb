require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/identity/v3/public/get_domain' do

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
      service = session.identity_service
      response = service.request :get_domain, :version => :v3 do |params|
        params[:id] = V3::Environment.openstack_admin[:auth_credentials][:domainId]
      end
      
      [200, 201].include?(response.status).must_equal true

      response.body.wont_be_nil
      response.headers.wont_be_nil
    end

    # validate_response "session is valid" do
    #   @session = Aviator::Session.new(
    #     config_file: V3::Environment.path,
    #     environment: 'openstack_admin'
    #   )
    #   @session.authenticate
    #   @session.authenticated?.must_equal true
    # end

    # validate_response "session is validated" do
    #   @session = Aviator::Session.new(
    #     config_file: V3::Environment.path,
    #     environment: 'openstack_admin',
    #     log_file: V3::Environment.log_file_path
    #   )
    #   @session.authenticate
    #   @session.validate.must_equal true

    # end
  end

end