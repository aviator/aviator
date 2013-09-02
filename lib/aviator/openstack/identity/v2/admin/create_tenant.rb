module Aviator

  define_request :create_tenant do

    meta :provider,      :openstack
    meta :service,       :identity
    meta :api_version,   :v2
    meta :endpoint_type, :admin

    link 'documentation',
         'http://docs.openstack.org/api/openstack-identity-service/2.0/content/'


    param :name,        required: true
    param :description, required: true
    param :enabled,     required: true


    def body
      {
        tenant: {
          name:        params[:name],
          description: params[:description],
          enabled:     params[:enabled]
        }
      }
    end


    def headers
      h = {}

      unless self.anonymous?
        h['X-Auth-Token'] = session_data[:access][:token][:id]
      end

      h
    end


    def http_method
      :post
    end


    def url
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'identity' }
      "#{ service_spec[:endpoints][0][:adminURL] }/tenants"
    end

  end

end