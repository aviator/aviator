module Aviator

  define_request :update_image_metadata, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/Update_Metadata-d1e5208.html'


    param :id,       :required => true
    param :metadata, :required => true


    def body
      {
        :metadata => params[:metadata]
      }
    end


    def headers
      super
    end


    def http_method
      :post
    end


    def url
      "#{ base_url }/images/#{ params[:id] }/metadata"
    end

  end

end
