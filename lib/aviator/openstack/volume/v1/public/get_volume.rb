module Aviator

  define_request :get_volume do
    meta :provider,       :openstack
    meta :service,        :volume
    meta :api_version,    :v1
    meta :endpoint_type,  :public

    link 'documentation', 'http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/GET_getVolume_v1__tenant_id__volumes__volume_id__v1__tenant_id__volumes.html'

    param :id, required: true

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

      "#{ service_spec[:endpoints][0][:publicURL] }/volumes/#{ params[:id] }"
    end


  end

end
