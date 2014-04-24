module Aviator

  define_request :list_roles do

    meta :provider,      :openstack
    meta :service,       :identity
    meta :api_version,   :v2
    meta :endpoint_type, :admin

    link 'documentation',
      'http://api.openstack.org/api-ref-identity.html#os-ksadm-admin-ext'


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
      service_spec = session_data[:catalog].find{|s| s[:type] == 'identity' }
      "#{ service_spec[:endpoints].find{|e| e[:interface] == 'admin'}[:url] }/OS-KSADM/roles/"
    end

  end

end
