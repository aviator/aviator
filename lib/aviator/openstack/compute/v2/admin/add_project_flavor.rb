module Aviator

  define_request :add_project_flavor, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
         'http://developer.openstack.org/api-ref-compute-v2-ext.html#ext-os-flavor-access'

    param :tenant_id,       required: true
    param :flavor_id,       required: true
    param :addTenantAccess, required: false, alias: :add_tenant_access
    param :tenant,          required: false



    def headers
      super

    end

    def body
      p = {
        addTenantAccess: {
          tenant: params[:tenant]
        }
      }
    end

    def http_method
      :post
    end


    def url
      "#{ base_url }/flavors/#{ params[:flavor_id] }/action"
    end

  end

end
