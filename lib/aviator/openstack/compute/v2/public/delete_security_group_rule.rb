module Aviator

  define_request :delete_security_group_rule, inherit: [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'https://wiki.openstack.org/wiki/Os-security-groups#Delete_Security_Group_Rule'

    link 'documentation',
         'http://api.openstack.org/api-ref-compute-ext.html#ext-os-security-group-default-rules'

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/GET_os-security-group-default-rules-v2_showSecGroupDefaultRule_v2__tenant_id__os-security-group-rules__security_group_rule_id__ext-os-security-group-default-rules.html'

    param :id, required: true

    def headers
      super
    end

    def http_method
      :delete
    end

    def url
      "#{ base_url }/os-security-group-rules/#{ params[:id]}"
    end

  end

end