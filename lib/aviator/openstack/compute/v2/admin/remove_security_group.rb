module Aviator

  define_request :remove_security_group, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/POST_os-admin-actions-v2_removeSecurityGroup_v2__tenant_id__servers__server_id__action_ext-action.html'

    param :id,    required: true
    param :name,  required: true

    def body
      {
        "removeSecurityGroup" => {
          "name" => params[:name]
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
      "#{ base_url }/servers/#{ params[:id] }/action"
    end

  end

end
