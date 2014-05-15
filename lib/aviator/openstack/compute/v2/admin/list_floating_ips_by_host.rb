module Aviator

  define_request :list_floating_ips_by_host, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/GET_os-floating-ips-bulk-v2_ListFloatingIPsBulkbyHost_v2__tenant_id__os-floating-ips-bulk__host_name__ext-os-floating-ips-bulk.html'

    param :host_name, required: false, alias: :name

    def headers
      super
    end


    def http_method
      :get
    end


    def url
      url = "#{ base_url }/os-floating-ips-bulk"
      url << "/#{ params[:host_name] }" unless params[:host_name].nil?
      url
    end

  end

end