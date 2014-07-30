module Aviator

  define_request :bulk_create_floating_ips, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/POST_os-floating-ips-bulk-v2_CreateFloatingIPsBulk__v2__tenant_id__os-floating-ips-bulk_ext-os-floating-ips-bulk.html'

    param :ip_range, required: true
    param :pool, required: true
    param :interface, required: false

    def body
      p = {
        floating_ips_bulk_create: {
          ip_range: params[:ip_range],
          pool: params[:pool]
        }
      }

      p[:floating_ips_bulk_create][:interface] = params[:interface] if params[:interface]

      p
    end

    def headers
      super
    end

    def http_method
      :post
    end


    def url
      "#{ base_url }/os-floating-ips-bulk"
    end

  end

end