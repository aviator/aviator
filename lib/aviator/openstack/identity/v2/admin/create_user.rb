module Aviator

  define_request :create_user do

    meta :provider,      :openstack
    meta :service,       :identity
    meta :api_version,   :v2
    meta :endpoint_type, :admin


    link 'documentation',
      'http://docs.openstack.org/api/openstack-identity-service/2.0/content/POST_addUser_v2.0_users_.html'


    param :name,      required: true
    param :password,  required: true

    param :email,     required: false
    param :enabled,   required: false
    param :tenant_id, required: false


    def body
      p = {
        user: {}
      }

      (required_params + optional_params - [:tenant_id]).each do |key|
        p[:user][key] = params[key] if params[key]
      end

      p[:user][:tenantId] = params[:tenant_id] if params[:tenant_id]

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
      :post
    end


    def url
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == 'identity' }
      "#{ service_spec[:endpoints][0][:adminURL] }/users"
    end

  end

end

