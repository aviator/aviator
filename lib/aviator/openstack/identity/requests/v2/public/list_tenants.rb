module Aviator
  
  define_request :list_tenants, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :identity
  
    link 'documentation',
         'http://docs.openstack.org/api/openstack-identity-service/2.0/content/GET_listTenants_v2.0_tokens_tenants_.html'

    link 'documentation bug',
         'https://bugs.launchpad.net/keystone/+bug/1218601'


    param :marker, :required => false
    param :limit,  :required => false


    def url
      str = "#{ base_url }/tenants"
      str += params_to_querystring(optional_params + required_params)
    end

  
    def headers
      super
    end
  
  
    def http_method
      :get
    end

  end
  
end
