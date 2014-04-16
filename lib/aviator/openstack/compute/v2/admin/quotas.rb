module Aviator

  define_request :quotas, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
         'http://api.openstack.org/api-ref-compute-v2-ext.html#ext-os-quota-sets'

    param :tenant_id, required: false

    def headers
      super
    end


    def http_method
      :get
    end


    def url
      "#{ base_url }/os-quota-sets/#{ params['tenant_id'] }"
    end

  end

end

