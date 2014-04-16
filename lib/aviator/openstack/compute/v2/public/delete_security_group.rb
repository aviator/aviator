module Aviator

  define_request :delete_security_group, inherit: [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/DELETE_os-security-groups-v2_deleteSecGroup_v2__tenant_id__os-security-groups__security_group_id__ext-os-security-groups.html'

    param :security_group_id, required: true, alias: :id


    def headers
      super
    end


    def http_method
      :delete
    end


    def url
      "#{ base_url }/os-security-groups/#{ params[:security_group_id] }"
    end

  end

end
