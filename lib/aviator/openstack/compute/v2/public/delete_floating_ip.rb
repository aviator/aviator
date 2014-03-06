module Aviator

  define_request :delete_floating_ip , inherit: [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/DELETE_os-floating-ips-v2_DeallocateFloatingIP_v2__tenant_id__os-floating-ips__id__ext-os-floating-ips.html'

    param :id, required: true


    def headers
      super
    end


    def http_method
      :delete
    end


    def url
      "#{ base_url }/os-floating-ips/#{ params[:id]}"
    end

  end

end