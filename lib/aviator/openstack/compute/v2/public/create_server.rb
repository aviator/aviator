module Aviator

  define_request :create_server, inherit: [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/CreateServers.html'

    link 'documentation',
         'http://developer.openstack.org/api-ref-compute-v2-ext.html#ext-os-block-device-mapping-v2-boot'

    link 'documentation',
         'https://bugs.launchpad.net/openstack-api-site/+bug/1215115'

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/POST_os-scheduler-hints-v2_createServer__v2__tenant_id__servers_ext-os-scheduler-hints.html'

    param :accessIPv4,  required: false, alias: :access_ipv4
    param :accessIPv6,  required: false, alias: :access_ipv6
    param :adminPass,   required: false, alias: :admin_pass
    param :imageRef,    required: false, alias: :image_ref
    param :flavorRef,   required: true,  alias: :flavor_ref
    param :metadata,    required: false
    param :name,        required: true
    param :networks,    required: false
    param :personality, required: false
    param :key_name,    required: false

    param :block_device_mapping_v2, required: false
    param :security_groups,         required: false
    param :availability_zone,       required: false
    param :'os:scheduler_hints',    required: false, alias: :scheduler_hints


    def body
      p = {
        server: {
          flavorRef: params[:flavorRef],
          imageRef:  params[:imageRef],
          name:      params[:name]
        }
      }

      keys = [
        :adminPass,
        :metadata,
        :personality,
        :networks,
        :accessIPv4,
        :accessIPv6,
        :key_name,
        :block_device_mapping_v2,
        :security_groups,
        :availability_zone
      ]

      keys.each do |key|
        p[:server][key] = params[key] if params[key]
      end

      if params[:'os:scheduler_hints']
        p[:'os:scheduler_hints'] = params[:'os:scheduler_hints']
      end

      p
    end


    def headers
      super
    end


    def http_method
      :post
    end


    def url
      if params[:block_device_mapping_v2] && !params[:block_device_mapping_v2].empty?
        "#{ base_url }/os-volumes_boot"
      else
        "#{ base_url }/servers"
      end
    end

  end

end
