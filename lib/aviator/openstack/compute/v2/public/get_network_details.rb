module Aviator

  define_request :get_network_details, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://api.openstack.org/api-ref-compute.html#ext-os-networks'


    param :id, :required => true


    def headers
      super
    end


    def http_method
      :get
    end


    def url
      "#{ base_url }/os-networks/#{ params[:id] }"
    end

  end

end
