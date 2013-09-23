module Aviator

  define_request :list_volumes do

    meta :provider,       :openstack
    meta :service,        :volume
    meta :api_version,    :v1
    meta :endpoint_type,  :public

    link 'documentation', 'http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/GET_getVolumesSimple_v1__tenant_id__volumes_v1__tenant_id__volumes.html'

    param :details,             required: false
    param :status,              required: false
    param :availability_zone,   required: false
    param :bootable,            required: false
    param :display_name,        required: false
    param :display_description, required: false
    param :volume_type,         required: false
    param :snapshot_id,         required: false
    param :size,                required: false


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
      str += "/detail" if params[:details]

      filters = []

      (optional_params + required_params - [:details]).each do |param_name|
        filters << "#{ param_name }=#{ params[param_name] }" if params[param_name]
      end

      str += "?#{ filters.join('&') }" unless filters.empty?

      str
    end

  end

end
