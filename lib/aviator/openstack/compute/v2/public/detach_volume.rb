module Aviator

  define_request :detach_volume, inherit: [:openstack, :common, :v2, :public, :base] do
    
    meta :service, :compute

    link 'documentation', 'http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Delete_Volume_Attachment.html'

    param :server_id, required: true
    param :volume_id, required: true

    def headers
      super
    end

    def http_method
      :delete
    end

    def url
      "#{ base_url }/servers/#{ params[:server_id] }/os-volume_attachments/#{ params[:volume_id] }"
    end
  end

end
