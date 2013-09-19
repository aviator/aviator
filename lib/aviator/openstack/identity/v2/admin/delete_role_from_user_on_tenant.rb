module Aviator

  define_request :delete_role_from_user_on_tenant do

    meta :provider,      :openstack
    meta :service,       :identity
    meta :api_version,   :v2
    meta :endpoint_type, :admin


    link 'documentation',
      'http://docs.openstack.org/api/openstack-identity-service/2.0/content/DELETE_deleteRoleFromUserOnTenant_v2.0_tenants__tenantId__users__userId__roles_OS-KSADM__roleId__.html'


    param :tenant_id, required: true
    param :user_id,   required: true
    param :role_id,   required: true


    def headers
      h = {}

      unless self.anonymous?
        h['X-Auth-Token'] = session_data[:access][:token][:id]
      end

      h
    end


    def http_method
      :delete
    end


    def url
      service_spec = session_data[:access][:serviceCatalog].find { |s| s[:type] == service.to_s }
      s  = "#{ service_spec[:endpoints][0][:adminURL] }/tenants/#{ params[:tenant_id] }"
      s += "/users/#{ params[:user_id] }"
      s += "/roles/OS-KSADM/#{ params[:role_id] }"
      s
    end

  end

end
