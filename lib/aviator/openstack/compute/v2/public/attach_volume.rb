module Aviator

  define_request :attach_volume, inherit: [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://docs.rackspace.com/servers/api/v2/cs-devguide/content/Attach_Volume_to_Server.html'

    param :server_id, required: true
    param :volume_id, required: true
    param :device,   required: true

    def body
      p = {
        "volumeAttachment" => {
          "volumeId" => params[:volume_id],
          "device" => params[:device]
        }
      }

      p
    end

    def headers
      super
    end


    def http_method
      :post
    end


    def url
      "#{ base_url }/servers/#{ params[:server_id] }/os-volume_attachments"
    end

  end

end