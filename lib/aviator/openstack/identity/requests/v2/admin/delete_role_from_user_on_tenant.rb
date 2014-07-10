module Aviator

  define_request :delete_role_from_user_on_tenant, :inherit => [:openstack, :common, :v2, :admin, :base] do

    meta :service, :identity


    link 'documentation',
         'http://docs.openstack.org/api/openstack-identity-service/2.0/content/DELETE_deleteRoleFromUserOnTenant_v2.0_tenants__tenantId__users__userId__roles_OS-KSADM__roleId__.html'


    param :tenant_id, :required => true
    param :user_id,   :required => true
    param :role_id,   :required => true


    def headers
      super
    end


    def http_method
      :delete
    end


    def url
      p = params
      "#{ base_url }/tenants/#{ p[:tenant_id] }/users/#{ p[:user_id] }/roles/OS-KSADM/#{ p[:role_id] }"
    end

  end

end
