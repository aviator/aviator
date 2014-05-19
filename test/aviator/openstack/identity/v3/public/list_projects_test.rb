require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/identity/v3/public/list_projects' do

    validate_response "session is validated" do
      @session = Aviator::Session.new(
        config_file: V3::Environment.path,
        environment: 'openstack_admin',
        log_file: V3::Environment.log_file_path
      )
      @session.authenticate
      keystone = @session.identity_service
      response = keystone.request(:list_projects)
      response.status.must_equal(200)
    end
  end

end