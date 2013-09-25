module Aviator

  define_request :migrate_server, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.openstack.org/api/openstack-compute/2/content/POST_migrate_v2__tenant_id__servers__server_id__action_ext-os-admin-actions.html'

    param :id,   required: true


    def body
      { migrate: nil }
    end


    def headers
      super
    end


    def http_method
      :post
    end


    def url
      "#{ base_url_for :admin }/servers/#{ params[:id] }/action"
    end

  end

end
