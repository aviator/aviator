module Aviator
  
  define_request :list_tenants do

    meta :provider,      :openstack
    meta :service,       :identity
    meta :api_version,   :v2
    meta :endpoint_type, :public
  
    link 'documentation',
         'http://docs.openstack.org/api/openstack-identity-service/2.0/content/GET_listTenants_v2.0_tokens_tenants_.html'

    link 'documentation bug',
         'https://bugs.launchpad.net/keystone/+bug/1218601'


    param :marker, required: false
    param :limit,  required: false


    def url
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'identity' }
      str = "#{ service_spec[:endpoints][0][:publicURL] }/tenants"
    
      filters = []
    
      (optional_params + required_params).each do |param_name|
        filters << "#{ param_name }=#{ params[param_name] }" if params[param_name]
      end
    
      str += "?#{ filters.join('&') }" unless filters.empty?
    
      str
    end

  
    def headers
      h = {}
    
      unless self.anonymous?
        h['X-Auth-Token'] = session_data[:access][:token][:id]
      end

      h
    end
  
  
    def http_method
      :get
    end

  end
  
end
