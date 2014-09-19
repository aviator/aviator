module Aviator

  define_request :create_floating_ip, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/POST_os-floating-ips-v2_AllocateFloatingIP__v2__tenant_id__os-floating-ips_ext-os-floating-ips.html'

    def body
      {
        :pool => nil
      }
    end


    def headers
      super
    end


    def http_method
      :post
    end


    def url
      "#{ base_url }/os-floating-ips"
    end

  end

end
