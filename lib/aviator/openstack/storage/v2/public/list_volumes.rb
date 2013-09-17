module Aviator

  define_request :list_volumes do

    meta :provider,           :openstack
    meta :service,            :storage
    meta :api_version,        :v2
    meta :endpoint_type,      :public

    link 'documentation', 'http://docs.openstack.org/api/openstack-block-storage/2.0/content/List_Volumes_Details.html'

    def headers
      {}.tap do |h|
        h['X-Auth-Token'] = session_data[:access][:token][:id] unless self.anonymous?
      end
    end

    def http_method
      :get
    end

    def url
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == service.to_s }

      str  = "#{ service_spec[:endpoints][0][:publicURL] }/volumes"
      str += "/details" if params[:details]

      filters = []

      (optional_params + required_params - [:details]).each do |param_name|
        filters << "#{ param_name }=#{ params[param_name] }" if params[param_name]
      end

      str += "?#{ filters.join('&') }" unless filters.empty?

      str
    end

  end

end
