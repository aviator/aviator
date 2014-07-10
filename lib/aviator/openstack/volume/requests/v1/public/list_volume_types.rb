module Aviator

  define_request :list_volume_types, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :provider,       :openstack
    meta :service,        :volume
    meta :api_version,    :v1
    meta :endpoint_type,  :public

    link 'documentation', 'http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/GET_getVolumeTypes_v1__tenant_id__types_v1__tenant_id__types.html'

    param :extra_specs, :required => false
    param :name,        :required => false

    def headers
      super
    end

    def http_method
      :get
    end

    def url
      "#{ base_url }/types"
    end

  end

end
