module Aviator

  define_request :list_flavors, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/List_Flavors-d1e4188.html'

    param :details, :required => false
    param :minDisk, :required => false, :alias => :min_disk
    param :minRam,  :required => false, :alias => :min_ram
    param :marker,  :required => false
    param :limit,   :required => false


    def headers
      super
    end


    def http_method
      :get
    end


    def url
      str  = "#{ base_url }/flavors"
      str += "/detail" if params[:details]
      str += params_to_querystring(optional_params + required_params - [:details])
    end

  end

end
