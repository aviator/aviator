module Aviator

  define_request :list_security_groups, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
         'http://api.openstack.org/api-ref-compute-ext.html#ext-os-security-groups'

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/GET_os-security-groups-v2_listSecGroups_v2__tenant_id__os-security-groups_ext-os-security-groups.html'

    def headers
      super
    end


    def http_method
      :get
    end


    def url
      "#{ base_url }/os-security-groups"
    end

  end

end
