module Aviator

  define_request :get_volume_type do
    meta :provider,         :openstack
    meta :service,          :volume
    meta :api_version,      :v1
    meta :endpoint_type,    :public

    link 'documentation', 'http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/GET_getVolumeType_v1__tenant_id__types__volume_type_id__v1__tenant_id__types.html'

    param :id, required: true

    def http_method
      :get
    end

    def headers
      {}.tap do |h|
        h['X-Auth-Token'] = session_data[:access][:token][:id] unless self.anonymous?
      end
    end


    def url
      service_spec = session_data[:access][:serviceCatalog].find{|s| s[:type] == service.to_s }

      "#{ service_spec[:endpoints][0][:publicURL] }/types/#{ params[:id] }"
    end


  end

end
