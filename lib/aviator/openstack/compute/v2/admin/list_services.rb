module Aviator

  define_request :list_services, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/GET_os-services-v2_listServices__v2__tenant_id__os-services_ext-os-services.html'

    def headers
      super
    end


    def http_method
      :get
    end


    def url
      "#{ base_url }/os-services"
    end

  end

end
