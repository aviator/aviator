require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/identity/v2/public/create_token' do

    def create_request
      klass.new(helper.admin_bootstrap_session_data) do |params|
        params[:username] = Environment.openstack_admin[:auth_credentials][:username]
        params[:password] = Environment.openstack_admin[:auth_credentials][:password]
      end
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      path = helper.request_path('identity', 'v2', 'public', 'create_token.rb')
      klass, request_name = Aviator::Service::RequestBuilder.build(path)
      klass
    end


    it 'has the correct endpoint type' do
      klass.endpoint_type.must_equal :public
    end


    it 'has the correct api version' do
        klass.api_version.must_equal :v2
    end


    it 'has the correct http method' do
      klass.http_method.must_equal :post
    end


    it 'has the correct list of required parameters' do
      klass.required_params.must_equal [:username, :password]
    end


    it 'has the correct list of optional parameters' do
      klass.optional_params.must_equal [:tenantName, :tenantId]
    end


    it 'has the correct url' do
      session_data = helper.admin_bootstrap_session_data
      url = "#{ session_data[:auth_service][:host_uri] }/v2.0/tokens"

      create_request.url.must_equal url
    end


    it 'has the correct headers' do
      create_request.headers?.must_equal false
    end


    it 'has the correct body' do
      p = {
        auth: {
          passwordCredentials: {
            username: Environment.openstack_admin[:auth_credentials][:username],
            password: Environment.openstack_admin[:auth_credentials][:password]
          }
        }
      }

      create_request.body.must_equal p
    end


    it 'leads to a valid response when provided with valid params' do
      service = Aviator::Service.new(
        provider: 'openstack',
        service:  'identity'
      )
      
      response = service.request :create_token, RequestHelper.admin_bootstrap_session_data do |params|
        params[:username] = Environment.openstack_admin[:auth_credentials][:username]
        params[:password] = Environment.openstack_admin[:auth_credentials][:password]
      end
      
      response.status.must_equal 200
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


    it 'leads to a valid response when provided with invalid params' do
      service = Aviator::Service.new(
        provider: 'openstack',
        service:  'identity'
      )
      
      response = service.request :create_token, RequestHelper.admin_bootstrap_session_data do |params|
        params[:username] = 'somebogususer'
        params[:password] = 'doesitreallymatter?'
      end
      
      response.status.must_equal 401
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end
    
  end

end