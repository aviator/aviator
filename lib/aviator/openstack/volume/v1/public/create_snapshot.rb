module Aviator

  define_request :create_snapshot, inherit: [:openstack, :common, :v2, :public, :base] do
    
    meta :service,        :volume
    meta :api_version,    :v1

    link 'documentation', 'http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/POST_createSnapshot_v1__tenant_id__snapshots_snapshots.html'

    param :snapshot,            required: true
    param :volume_id,           required: true
    param :force,               required: false
    param :display_name,        required: true
    param :display_description, required: true
    
    def body
      p = {
        snapshot: {
         display_name:          params[:display_name],
         display_description:   params[:display_description],
         volume_id:             params[:volume_id],
         force:                 params[:force]
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
      "#{ base_url }/volumes/#{ params[:id] }/snapshots"
    end
  end

end
