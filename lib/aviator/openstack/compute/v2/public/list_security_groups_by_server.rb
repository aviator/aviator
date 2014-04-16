module Aviator

  define_request :list_security_groups_by_server, inherit: [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    # DOCUMENT CAVEAT
    # the correct url is: v2/{tenant_id}/servers/{server_id}/os-security-groups
    # NOT: v2/{tenant_id}/os-security-groups/servers/{server_id}/os-security-groups

    link 'documentation',
         'http://api.openstack.org/api-ref-compute-ext.html#ext-os-security-groups'

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/GET_os-security-groups-v2_listSecGroupsByServer_v2__tenant_id__os-security-groups_servers__server_id__os-security-groups_ext-os-security-groups.html'

    param :server_id, required: true

    def headers
      super
    end


    def http_method
      :get
    end


    def url
      "#{ base_url }/servers/#{ params[:server_id] }/os-security-groups"
    end

  end

end
