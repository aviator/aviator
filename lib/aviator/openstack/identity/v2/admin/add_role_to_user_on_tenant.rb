module Aviator

  define_request :add_role_to_user_on_tenant do

    meta :provider,      :openstack
    meta :service,       :identity
    meta :api_version,   :v2
    meta :endpoint_type, :admin


    link 'documentation',
      'http://docs.openstack.org/api/openstack-identity-service/2.0/content/PUT_addRolesToUserOnTenant_v2.0_tenants__tenantId__users__userId__roles_OS-KSADM__roleId__.html'


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
      :put
    end


    def url
      service_spec = session_data[:access][:serviceCatalog].find { |s| s[:type] == service.to_s }
      "#{ service_spec[:endpoints][0][:adminURL] }" \
      "/tenants/#{ params[:tenant_id] }" \
      "/users/#{ params[:user_id] }" \
      "/roles/OS-KSADM/#{ params[:role_id] }"
    end

  end

end
