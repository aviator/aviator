module Aviator

  define_request :add_floating_ip, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/POST_os-floating-ips-v2_AddFloatingIP__v2__tenant_id__servers__server_id__action_ext-os-floating-ips.html#POST_os-floating-ips-v2_AddFloatingIP__v2__tenant_id__servers__server_id__action_ext-os-floating-ips-Request'

    param :server_id, :required => true
    param :address,   :required => true

    def body
      {
        :addFloatingIp => {
          :address => params[:address]
        }
      }
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
