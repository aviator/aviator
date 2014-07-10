module Aviator
  
  define_request :get_image_details, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/Get_Image_Details-d1e4848.html'

    param :id, :required => true


    def headers
      super
    end


    def http_method
      :get
    end


    def url
      "#{ base_url }/images/#{ params[:id]}"
    end

  end

end