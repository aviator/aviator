module Aviator

  define_request :list_networks, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://api.openstack.org/api-ref-compute.html#ext-os-networks'


    def headers
      super
    end


    def http_method
      :get
    end


    def url
      "#{ base_url }/os-networks"
    end

  end

end
