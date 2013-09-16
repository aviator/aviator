module Aviator

  define_request :update_tenant do

    meta :provider,      :openstack
    meta :service,       :identity
    meta :api_version,   :v2
    meta :endpoint_type, :admin


    link 'documentation',
      'http://docs.openstack.org/api/openstack-identity-service/2.0/content/POST_updateTenant_v2.0_tenants__tenantId__.html'


    param :id,          required: true
    param :name,        required: false
    param :enabled,     required: false
    param :description, required: false


    def body
      p = {
        tenant: {}
      }

      [:name, :enabled, :description].each do |key|
        p[:tenant][key] = params[key] if params[key]
      end

      p
    end


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
      "#{ service_spec[:endpoints][0][:adminURL] }/tenants/#{ params[:id] }"
    end

  end

end
