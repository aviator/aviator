module Aviator

  define_request :remove_floating_ip, inherit: [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/POST_os-floating-ips-v2_RemoveFloatingIP_v2__tenant_id__servers__server_id__action_ext-os-floating-ips.html'

    param :server_id, required: true
    param :address,   required: true

    def body
      p = {
        "removeFloatingIp" => {
          "address" => params[:address]
        }
      }

      p
    end

    def headers
      super
    end


    def http_method
      :post
    end


    def url
      "#{ base_url }/servers/#{ params[:server_id] }/action"
    end

  end

end