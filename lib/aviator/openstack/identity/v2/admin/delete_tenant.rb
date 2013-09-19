module Aviator

  define_request :delete_tenant do

    meta :provider,      :openstack
    meta :service,       :identity
    meta :api_version,   :v2
    meta :endpoint_type, :admin

    link 'documentation',
      'http://docs.openstack.org/api/openstack-identity-service/2.0/content/DELETE_deleteTenant_v2.0_tenants__tenantId__.html'

    param :id, required: true


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
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == service.to_s }

      "#{ service_spec[:endpoints][0][:adminURL] }/tenants/#{ params[:id]}"
    end

  end

end
