require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/identity/requests/v3/public/create_token' do

    def create_request(&block)
      block ||= lambda do |params|
        params[:username] = Environment.openstack_admin[:auth_credentials][:username]
        params[:password] = Environment.openstack_admin[:auth_credentials][:password]
      end

      klass.new(helper.admin_bootstrap_session_data, &block)
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'identity', 'v3', 'public', 'create_token.rb')
    end


    validate_attr :anonymous? do
      klass.anonymous?.must_equal true
    end


    validate_attr :api_version do
      klass.api_version.must_equal :v3
    end


    validate_attr :body do
      p = {
        :auth => {
          :identity => {
            :methods =>['password'],
            :password => {
              :user => {
                :name => Environment.openstack_admin[:auth_credentials][:username],
                :password => Environment.openstack_admin[:auth_credentials][:password]
              }
            }
          }
        }
      }

      create_request.body.must_equal p
    end


    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :public
    end


    validate_attr :headers do
      create_request.headers?.must_equal true
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :post
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal [
        :domainId,
        :domainName,
        :password,
        :tenantId,
        :tenantName,
        :tokenId,
        :userId,
        :username
      ]
    end


    validate_attr :required_params do
      klass.required_params.must_equal []
    end


    validate_attr :url do
      session_data = helper.admin_bootstrap_session_data
      url = "#{ session_data[:auth_service][:host_uri] }/v3/auth/tokens"

      create_request.url.must_equal url
    end


    validate_attr :url, 'when the host uri contains the api version' do
      host_uri = 'http://x.y.z:5000/v3'

      request = klass.new({ :auth_service => { :host_uri => host_uri } }) do |params|
        params[:username] = Environment.openstack_admin[:auth_credentials][:username]
        params[:password] = Environment.openstack_admin[:auth_credentials][:password]
      end

      request.url.must_equal "#{ host_uri }/auth/tokens"
    end


    validate_attr :param_aliases do
      aliases = {
        :domain_id   => :domainId,
        :domain_name => :domainName,
        :token_id    => :tokenId,
        :tenant_name => :tenantName,
        :tenant_id   => :tenantId,
        :user_id     => :userId
      }

      klass.param_aliases.must_equal aliases
    end


    validate_response 'parameters are invalid' do
      service = Aviator::Service.new(
        :provider => 'openstack',
        :service  => 'identity',
        :default_session_data => RequestHelper.admin_bootstrap_session_data(:v3)
      )

      response = service.request :create_token do |params|
        params[:username] = 'somebogususer'
        params[:password] = 'doesitreallymatter?'
        params[:domain_id] = "default"
      end

      response.status.must_equal 401
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


    validate_response 'parameters are valid' do
      service = Aviator::Service.new(
        :provider => 'openstack',
        :service  => 'identity',
        :default_session_data => RequestHelper.admin_bootstrap_session_data(:v3)
      )

      response = service.request :create_token do |params|
        params[:username]  = Environment.openstack_admin[:auth_credentials][:username]
        params[:password]  = Environment.openstack_admin[:auth_credentials][:password]
        params[:domain_id] = "default"
      end

      response.status.must_equal 201
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


    validate_response 'provided with a token' do
      service = Aviator::Service.new(
        :provider => 'openstack',
        :service  => 'identity',
        :default_session_data => RequestHelper.admin_bootstrap_session_data(:v3)
      )

      response = service.request :create_token do |params|
        params[:username]  = Environment.openstack_admin[:auth_credentials][:username]
        params[:password]  = Environment.openstack_admin[:auth_credentials][:password]
        params[:domain_id] = "default"
      end

      token = response.headers["x-subject-token"]

      response = service.request :create_token do |params|
        params[:token_id] = token
      end

      response.status.must_equal 201
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end

  end

end
