module Aviator

  define_request :get_default_quotas, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
      'http://api.openstack.org/api-ref-compute-v2-ext.html#ext-os-quota-sets'

    link 'documentation',
      'http://docs.openstack.org/api/openstack-compute/2/content/GET_os-quota-sets-v2_getDefaults_v2__tenant_id__os-quota-sets_defaults_ext-os-quota-sets.html'


    def headers
      super
    end


    def http_method
      :get
    end


    def url
      "#{ base_url }/os-quota-sets/defaults"
    end

  end

end
