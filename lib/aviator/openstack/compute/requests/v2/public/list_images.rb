module Aviator
  
  define_request :list_images, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/List_Images-d1e4435.html'

    param :details,        :required => false
    param :server,         :required => false
    param :name,           :required => false
    param :status,         :required => false
    param 'changes-since', :required => false, :alias => :changes_since
    param :marker,         :required => false
    param :limit,          :required => false
    param :type,           :required => false


    def headers
      super
    end


    def http_method
      :get
    end


    def url
      str  = "#{ base_url }/images"
      str += "/detail" if params[:details]
      str += params_to_querystring(optional_params + required_params - [:details])
    end

  end

end