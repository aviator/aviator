module Aviator

  define_request :confirm_server_resize, :inherit => [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/Confirm_Resized_Server-d1e3868.html'

    param :id, :required => true


    def body
      {
        :confirmResize => nil
      }
    end


    def headers
      super
    end


    def http_method
      :post
    end


    def url
      "#{ base_url }/servers/#{ params[:id] }/action"
    end

  end

end
