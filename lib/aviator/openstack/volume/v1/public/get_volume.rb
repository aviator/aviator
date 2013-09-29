module Aviator

  define_request :get_volume, inherit: [:openstack, :common, :v2, :public, :base] do
    meta :provider,       :openstack
    meta :service,        :volume
    meta :api_version,    :v1
    meta :endpoint_type,  :public

    link 'documentation', 'http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/GET_getVolume_v1__tenant_id__volumes__volume_id__v1__tenant_id__volumes.html'

    param :id, required: true

    def headers
      super
    end

    def http_method
      :get
    end

    def url
      "#{ base_url }/volumes/#{ params[:id] }"
    end


  end

end
