module Aviator

  define_request :delete_tenant, :inherit => [:openstack, :common, :v2, :admin, :base] do

    meta :service, :identity

    link 'documentation',
      'http://docs.openstack.org/api/openstack-identity-service/2.0/content/DELETE_deleteTenant_v2.0_tenants__tenantId__.html'

    param :id, :required => true


    def headers
      super
    end


    def http_method
      :delete
    end


    def url
      "#{ base_url }/tenants/#{ params[:id]}"
    end

  end

end
