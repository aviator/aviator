require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/public/list_images' do

    def create_request(session_data = new_session_data)
      klass.new(session_data)
    end


    def new_session_data
      service = Aviator::Service.new(
        provider: 'openstack',
        service:  'identity'
      )
      
      bootstrap = RequestHelper.admin_bootstrap_session_data
      
      response = service.request :create_token, session_data: bootstrap do |params|
        auth_credentials = Environment.openstack_admin[:auth_credentials]
        auth_credentials.each { |key, value| params[key] = auth_credentials[key] }
      end
      
      response.body
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'public', 'list_images.rb')
    end


    validate :anonymous? do
      klass.anonymous?.must_equal false
    end
    
    
    validate :api_version do
      klass.api_version.must_equal :v2
    end


    validate :body do
      klass.body?.must_equal false    
      create_request.body?.must_equal false
    end
    
    
    validate :endpoint_type do
      klass.endpoint_type.must_equal :public
    end
    

    validate :headers do
      session_data = new_session_data
      
      headers = { 'X-Auth-Token' => session_data[:access][:token][:id] }

      request = create_request(session_data)

      request.headers.must_equal headers
    end
    
    
    validate :http_method do
      create_request.http_method.must_equal :get
    end


    validate :optional_params do
      klass.optional_params.must_equal [
        :details,
        :server,
        :name,
        :status,
        'changes-since',
        :marker,
        :limit,
        :type
      ]
    end


    validate :required_params do
      klass.required_params.must_equal []
    end


    validate :url do
      session_data = new_session_data
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'compute' }
      url          = "#{ service_spec[:endpoints][0][:publicURL] }/images"
            
      params = [
        [ :details,  true                             ],
        [ :name,    'cirros-0.3.1-x86_64-uec-ramdisk' ],
        [ :status,  'ACTIVE'                          ],
        [ :type,    'application/vnd.openstack.image' ]
      ]
    
      url += "/detail" if params.first[1]
    
      filters = []
    
      params[1, params.length-1].each { |pair| filters << "#{ pair[0] }=#{ pair[1] }" }
    
      url += "?#{ filters.join('&') }" unless filters.empty?
      
      request = klass.new(session_data) do |p|
        params.each { |pair| p[pair[0]] = pair[1] }
      end
      
          
      request.url.must_equal url
    end
    
    
    validate_response 'no parameters are provided' do
      service = Aviator::Service.new(
        provider: 'openstack',
        service:  'compute',
        default_session_data: new_session_data
      )
      
      response = service.request :list_images
      
      response.status.must_equal 200
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end
    
    
    validate_response 'parameters are invalid' do
      service = Aviator::Service.new(
        provider: 'openstack',
        service:  'compute',
        default_session_data: new_session_data
      )
      
      response = service.request :list_images do |params|
        params[:name] = "nonexistentimagenameherpderp"
      end
      
      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:images].length.must_equal 0
      response.headers.wont_be_nil
    end
    
    
    validate_response 'parameters are valid' do
      service = Aviator::Service.new(
        provider: 'openstack',
        service:  'compute',
        default_session_data: new_session_data
      )
      
      response = service.request :list_images do |params|
        params[:details] = true
        params[:name] = "cirros-0.3.1-x86_64-uec-ramdisk"
      end
      
      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:images].length.must_equal 1
      response.headers.wont_be_nil
    end    

  end

end