module Aviator

  define_request :list_users_for_a_tenant, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service,       :identity

    link 'documentation',
      'http://docs.openstack.org/api/openstack-identity-service/2.0/content/GET_listUsersForTenant_v2.0_tenants__tenantId__users_.html'

    param :tenant_id, required: true

    def headers
      h = {}

      unless self.anonymous?
        h['X-Auth-Token'] = session_data.token
      end

      h
    end


    def http_method
      :get
    end


    def url
      "#{ base_url }/tenants/#{ params[:tenant_id] }/users"
    end

  end

end