module Aviator

  define_request :reboot_server, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/Reboot_Server-d1e3371.html'

    param :id,   :required => true
    param :type, :required => false


    def body
      p = {
        :reboot => {
          :type => params[:type] || 'SOFT'
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
      "#{ base_url }/servers/#{ params[:id] }/action"
    end

  end

end
