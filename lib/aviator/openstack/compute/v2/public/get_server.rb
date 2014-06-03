module Aviator

  define_request :get_server, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/Get_Server_Details-d1e2623.html'

    param :id, :required => true

    def headers
      super
    end


    def http_method
      :get
    end


    def url
      "#{ base_url }/servers/#{ params[:id] }"
    end

  end

end
