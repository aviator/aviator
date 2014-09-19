module Aviator

  define_request :list_floating_ips, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/GET_os-floating-ips-v2_ListFloatingIPs__v2__tenant_id__os-floating-ips_ext-os-floating-ips.html'

    def headers
      super
    end


    def http_method
      :get
    end


    def url
      str  = "#{ base_url }/os-floating-ips"
    end

  end

end
