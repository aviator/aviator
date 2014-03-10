module Aviator

  define_request :get_user, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :provider,      :openstack
    meta :service,       :identity
    meta :api_version,   :v2
    meta :endpoint_type, :admin


    link 'documentation',
      'http://docs.openstack.org/api/openstack-identity-service/2.0/content/POST_updateUser_v2.0_users__userId__.html'

    param :id, required: true


    def headers
      super
    end


    def http_method
      :get
    end


    def url
      "#{ base_url }/users/#{ params[:id] }"
    end

  end

end
