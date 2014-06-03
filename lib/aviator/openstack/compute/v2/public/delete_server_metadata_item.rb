module Aviator

  define_request :delete_server_metadata_item, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/Delete_Metadata_Item-d1e5790.html'


    param :id,  :required => true
    param :key, :required => true


    def headers
      super
    end


    def http_method
      :delete
    end


    def url
      "#{ base_url }/servers/#{ params[:id] }/metadata/#{ params[:key] }"
    end

  end

end
