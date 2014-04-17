module Aviator

  define_request :list_hypervisors, :inherit => [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
         'http://api.openstack.org/api-ref-compute-v2-ext.html#ext-os-hypervisors'

    def headers
      super
    end


    def http_method
      :get
    end


    def url
      "#{ base_url }/os-hypervisors"
    end

  end

end

