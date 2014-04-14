module Aviator

  define_request :get_quotas, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
      'http://api.openstack.org/api-ref-compute-v2-ext.html#ext-os-quota-sets'

    link 'documentation',
      'http://docs.openstack.org/api/openstack-compute/2/content/GET_os-quota-sets-v2_showQuota_v2__tenant_id__os-quota-sets__tenant_id__ext-os-quota-sets.html'

    param :tenant_id, required: true


    def headers
      super
    end


    def http_method
      :get
    end


    def url
      "#{ base_url }/os-quota-sets/#{ params[:tenant_id] }"
    end

  end

end
