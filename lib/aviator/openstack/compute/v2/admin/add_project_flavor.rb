module Aviator

  define_request :add_project_flavor, inherit: [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://developer.openstack.org/api-ref-compute-v2-ext.html#ext-os-flavor-access'

    param :id, required: true


    def headers
      super
    end


    def http_method
      :post
    end


    def url
      "#{ base_url }/flavors/#{ params[:id] }/action"
    end

  end

end
