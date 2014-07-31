module Aviator

  define_request :bulk_delete_floating_ips, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/POST_os-floating-ips-bulk-v2_DeleteFloatingIPBulk__v2__tenant_id__os-floating-ips-bulk_delete_ext-os-floating-ips-bulk.html'

    link 'Incorrect documentation: Method should have been PUT not POST',
         'https://github.com/openstack/nova/blob/master/nova/tests/integrated/test_api_samples.py#L1067'

    param :ip_range, required: true

    def body
      p = {
        "ip_range" => params[:ip_range]
      }

      p
    end

    def headers
      super
    end

    def http_method
      :put
    end


    def url
      "#{ base_url }/os-floating-ips-bulk/delete"
    end

  end

end