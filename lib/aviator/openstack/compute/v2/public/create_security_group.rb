module Aviator

  define_request :create_security_group, inherit: [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    # DOCUMENTATION CAVEAT
    # While provided docs is in v2, it might actually refer to v1 specs

    # [PARAMETER]
    # 'description' is supposedly optional but returns a
    # {"badRequest"=>
    #   {"message"=>"Security group description is not a string or unicode",
    #     "code"=>400}}
    # if not provided
    #
    # [BODY]
    # 'security_group' is supposedly 'addSecurityGroup'
    # 'addSecurityGroup' returns a
    # {"computeFault": {"message": "Unable to process the contained instructions", "code": 422}}

    link 'documentation',
         'http://api.openstack.org/api-ref-compute-ext.html#ext-os-security-groups'

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/POST_os-security-groups-v2_createSecGroup_v2__tenant_id__os-security-groups_ext-os-security-groups.html'

    param :name,        required: true
    param :description, required: true

    def body
      p = {
        :security_group => {
          name: params[:name],
          description: params[:description]
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
      "#{ base_url }/os-security-groups"
    end

  end

end