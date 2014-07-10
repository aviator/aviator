module Aviator

  define_request :create_image, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/Create_Image-d1e4655.html'

    param :id,       :required => true
    param :metadata, :required => false
    param :name,     :required => true


    def body
      p = {
        :createImage => {
          :name => params[:name]
        }
      }
      
      [:metadata].each do |key|
        p[:createImage][key] = params[key] if params[key]
      end

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
