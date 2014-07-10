module Aviator

  define_request :get_flavor_details, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/Get_Flavor_Details-d1e4317.html'

    param :id, :required => true


    def headers
      super
    end


    def http_method
      :get
    end


    def url
      "#{ base_url }/flavors/#{ params[:id] }"
    end

  end

end
