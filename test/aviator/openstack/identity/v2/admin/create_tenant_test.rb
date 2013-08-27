require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/identity/v2/admin/create_tenant' do

    def create_request
      klass.new(helper.admin_session_data) do |params|
        params[:name]        = 'Project'
        params[:description] = 'My Project'
        params[:enabled]     = true
      end
    end
    

    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      path = helper.request_path('identity', 'v2', 'admin', 'create_tenant.rb')
      klass, request_name = Aviator::Service::RequestBuilder.build(path)
      klass
    end


    describe '::endpoint_type' do
      
      it 'returns :admin' do
        klass.endpoint_type.must_equal :admin
      end
      
    end


    describe '::api_version' do
      
      it 'returns :v2' do
        klass.api_version.must_equal :v2
      end
      
    end
        
    
    describe '::http_method' do
      
      it 'returns :post' do
        klass.http_method.must_equal :post
      end
      
    end
    
    
    describe '::required_params' do
      
      it 'returns the list of required params' do
        klass.required_params.must_equal [:name, :description, :enabled]
      end
      
    end
    
    
    describe '#url' do
      
      it 'returns the correct value' do
        session_data = helper.admin_session_data
        service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'identity' }
        url = "#{ service_spec[:endpoints][0][:adminURL] }/tenants"
        
        request = create_request
        
        request.url.must_equal url
      end
      
    end
    
    
    describe '#headers' do
      
      it 'returns valid headers' do
        headers = {
          'X-Auth-Token' => helper.admin_session_data[:access][:token][:id]
        }
        
        request = create_request
        
        request.headers.must_equal headers
      end
      
    end
    
    
    describe '#body' do
      
      it 'returns a valid body' do
        params = {
          name:        'Project',
          description: 'My Project',
          enabled:      true
        }
        
        body = {
          tenant: params
        }

        request = klass.new(helper.admin_session_data) do |p|
          params.each do |k,v|
            p[k] = params[k]
          end
        end
        
        request.body.must_equal body
      end
      
    end

  end

end