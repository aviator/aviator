require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/identity/v3/public/list_user_roles_on_domain' do

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

    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'identity', 'v3', 'public', 'list_user_roles_on_domain.rb')
    end


    def setup_dependencies
      @keystone ||= session.identity_service
      @domain   ||= @keystone.request(:list_domains, version: :v3).body[:domains].first
      @role     ||= @keystone.request(:list_roles, version: :v2).body[:roles].first

      @user = @keystone.request(:create_user, version: :v2) do |p|
        p.name      = 'roled_user'
        p.password  = '123qwe'
      end.body[:user]

      @keystone.request(:grant_role_to_user_on_domain, version: :v3) do |params|
        params[:domain_id]  = @domain.id
        params[:role_id]    = @role.id
        params[:user_id]    = @user.id
      end
    end


    def teardown_dependencies
      @keystone.request(:delete_user){|p| p.id = @user.id}
    end


    validate_attr :required_params do
      klass.required_params.must_equal [:domain_id, :user_id]
    end


    validate_response 'parameters are valid' do
      setup_dependencies

      response = @keystone.request(:list_user_roles_on_domain, version: :v3) do |params|
        params[:domain_id]  = @domain.id
        params[:user_id]    = @user.id
      end

      response.status.must_equal 200
      response.body[:roles].wont_be_nil
      response.body[:roles].map(&:id).must_include @role.id
      response.headers.wont_be_nil

      teardown_dependencies
    end


    validate_response 'domain id is invalid' do
      setup_dependencies

      response = @keystone.request(:list_user_roles_on_domain, version: :v3) do |params|
        params[:domain_id]  = 'nonexistent'
        params[:user_id]    = @user.id
      end

      response.status.must_equal 404
      response.headers.wont_be_nil

      teardown_dependencies
    end


    validate_response 'user id is invalid' do
      setup_dependencies

      response = @keystone.request(:list_user_roles_on_domain, version: :v3) do |params|
        params[:domain_id]  = @domain.id
        params[:user_id]    = 'nonexistent'
      end

      response.status.must_equal 404
      response.headers.wont_be_nil

      teardown_dependencies
    end

  end
end