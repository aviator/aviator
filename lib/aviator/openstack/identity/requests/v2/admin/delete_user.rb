module Aviator

  define_request :delete_user do

    meta :provider,      :openstack
    meta :service,       :identity
    meta :api_version,   :v2
    meta :endpoint_type, :admin

    link 'documentation',
      'http://docs.openstack.org/api/openstack-identity-service/2.0/content/DELETE_deleteUser_v2.0_users__userId__.html'

    param :id, :required => true


    def headers
      h = {}

      unless self.anonymous?
        h['X-Auth-Token'] = session_data[:body][:access][:token][:id]
      end

      h
    end


    def http_method
      :delete
    end


    def url
      service_spec = session_data[:body][:access][:serviceCatalog].find{|s| s[:type] == service.to_s }
      "#{ service_spec[:endpoints][0][:adminURL] }/users/#{ params[:id]}"
    end

  end

end
