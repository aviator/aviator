module Aviator

  define_request :lock_server, :inherit => [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/POST_lock_v2__tenant_id__servers__server_id__action_ext-os-admin-actions.html'

    param :id, :required => true


    def body
      { :lock => nil }
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
