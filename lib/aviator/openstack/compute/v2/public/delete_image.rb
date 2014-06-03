module Aviator
  
  define_request :delete_image, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/Delete_Image-d1e4957.html'

    param :id, :required => true


    def headers
      super
    end


    def http_method
      :delete
    end


    def url
      "#{ base_url }/images/#{ params[:id]}"
    end

  end

end