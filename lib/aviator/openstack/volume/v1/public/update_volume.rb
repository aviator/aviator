module Aviator

  define_request :update_volume, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service,       :volume
    meta :api_version,   :v1

    link 'documentation', 'http://docs.rackspace.com/cbs/api/v1.0/cbs-devguide/content/PUT_renameVolume_v1__tenant_id__volumes__volume_id__v1__tenant_id__volumes.html'

    param :id,                  :required => true
    param :display_name,        :required => false
    param :display_description, :required => false


    def body
      p = { :volume => {} }

      [:display_name, :display_description].each do |key|
        p[:volume][key] = params[key] if params[key]
      end

      p
    end


    def headers
      super
    end


    def http_method
      :put
    end


    def url
      "#{ base_url }/volumes/#{ params[:id] }"
    end

  end


end
