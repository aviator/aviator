module Aviator

  define_request :create_security_group_rule, inherit: [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'https://wiki.openstack.org/wiki/Os-security-groups#Create_Security_Group_Rule'

    link 'documentation',
         'http://api.openstack.org/api-ref-compute-ext.html#ext-os-security-group-default-rules'

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/POST_os-security-groups-v2_createSecGroup_v2__tenant_id__os-security-groups_ext-os-security-groups.html'


    param :ip_protocol,     required: true
    param :from_port,       required: true
    param :to_port,         required: true
    param :cidr,            required: true
    param :parent_group_id, required: true
    param :group_id,        required: false

    def body
      p = {
        :security_group_rule => {
          :ip_protocol      => params[:ip_protocol],
          :from_port        => params[:from_port],
          :to_port          => params[:to_port],
          :cidr             => params[:cidr],
          :parent_group_id  => params[:parent_group_id],
          :group_id         => params[:group_id]
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
      "#{ base_url }/os-security-group-rules"
    end

  end

end