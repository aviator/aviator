require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/identity/v3/public/create_token' do

    validate_response 'parameters are valid' do
      #puts V3::Environment.openstack_admin[:auth_service].inspect
      #puts RequestHelper.admin_bootstrap_session_data
      service = Aviator::Service.new(
        provider: 'openstack',
        log_file: V3::Environment.log_file_path,
        service:  'identity',
        default_session_data: RequestHelper.admin_bootstrap_v3_session_data
      )

      response = service.request :create_token do |params|
        params[:username] = V3::Environment.openstack_admin[:auth_credentials][:username]
        params[:password] = V3::Environment.openstack_admin[:auth_credentials][:password]
        params[:domainId] = V3::Environment.openstack_admin[:auth_credentials][:domainId]
      end

      [200, 201].include?(response.status).must_equal true

      response.body.wont_be_nil
      response.headers.wont_be_nil
    end

    validate_response "session is valid" do
      @session = Aviator::Session.new(
        config_file: V3::Environment.path,
        environment: 'openstack_admin'
      )
      @session.authenticate
      @session.authenticated?.must_equal true
    end

    validate_response "session is validated" do
      @session = Aviator::Session.new(
        config_file: V3::Environment.path,
        environment: 'openstack_admin',
        log_file: V3::Environment.log_file_path
      )
      @session.authenticate

      @session.validate.must_equal true

    end
  end

end