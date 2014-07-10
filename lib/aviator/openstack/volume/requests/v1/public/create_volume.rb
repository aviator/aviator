module Aviator

  define_request :create_volume, :inherit => [:openstack, :common, :v2, :public, :base] do
    
    meta :service,        :volume
    meta :api_version,    :v1

    link 'documentation', 'http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/POST_createVolume_v1__tenant_id__volumes_v1__tenant_id__volumes.html'

    param :display_name,        :required => true
    param :display_description, :required => true
    param :size,                :required => true
    param :volume_type,         :required => false
    param :availability_zone,   :required => false
    param :snapshot_id,         :required => false
    param :metadata,            :required => false

    def body
      p = {
        :volume => {
         :display_name          => params[:display_name],
         :display_description   => params[:display_description],
         :size                  => params[:size]
        }
      }

      optional_params.each do |key|
          p[:volume][key] = params[key] if params[key]
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
      "#{ base_url }/volumes"
    end
  end

end
