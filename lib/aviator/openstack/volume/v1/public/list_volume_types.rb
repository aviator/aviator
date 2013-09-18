module Aviator

  define_request :list_volume_types do

    meta :provider,           :openstack
    meta :service,            :volume
    meta :api_version,        :v1
    meta :endpoint_type,      :public

    link 'documentation', 'http://docs.openstack.org/api/openstack-block-storage/2.0/content/List_Volumes_Details.html'

    param :extra_specs,         required: false
    param :name,                required: false

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

      str  = "#{ service_spec[:endpoints][0][:publicURL] }/types"
    end

  end

end
