module Aviator

  define_request :create_flavor, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
         'http://developer.openstack.org/api-ref-compute-v2-ext.html#ext-os-flavor-access'

    param :tenant_id, required: false
    param :name, required: true
    param :ram,  required: true
    param :vcpus,  required: true
    param :disk,   required: true
    param :id, required: false

    def headers
      super
    end

    def body
      p = {
        flavor: {
          name: params[:name],
          ram: params[:ram],
          vcpus: params[:vcpus],
          disk: params[:disk],
          id: params[:id],
          tenant_id: params[:tenant_id],
        }
      }
    end


    def http_method
      :post
    end


    def url
      "#{ base_url }/flavors"
    end

  end

end
