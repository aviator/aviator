module Aviator

  define_request :delete_server, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/Delete_Server-d1e2883.html'

    param :id, :required => true


    def headers
      super
    end


    def http_method
      :delete
    end


    def url
      "#{ base_url }/servers/#{ params[:id] }"
    end

  end

end
