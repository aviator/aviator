module Aviator

  define_request :list_tenants, :inherit => [:openstack, :common, :v2, :admin, :base] do

    meta :service, :identity

    link 'documentation',
         'http://docs.openstack.org/api/openstack-identity-service/2.0/content/GET_listTenants_v2.0_tenants_Tenant_Operations.html'

    link 'documentation bug',
         'https://bugs.launchpad.net/keystone/+bug/1218601'


    param :marker, :required => false
    param :limit,  :required => false


    def headers
      super
    end


    def http_method
      :get
    end


    def url
      str  = "#{ base_url }/tenants"
      str += params_to_querystring(optional_params + required_params)
    end

  end

end