module Aviator

  define_request :list_floating_ip_pools, inherit: [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/GET_os-floating-ip-pools-v2_listFloatingIpPools_v2__tenant_id__os-floating-ip-pools_ext-os-floating-ip-pools.html'


    def headers
      super
    end


    def http_method
      :get
    end


    def url
      "#{ base_url }/os-floating-ip-pools"
    end

  end

end