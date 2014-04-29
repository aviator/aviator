module Aviator

  define_request :get_projects_by_user_id, inherit: [:openstack, :common, :v3, :public, :base] do

    meta :service, :identity
    meta :api_version,   :v3

    link 'documentation',
      'http://api.openstack.org/api-ref-identity-v3.html#User_Calls'


    param :id, required: true

    def headers
      super
    end


    def http_method
      :get
    end


    def url
      "#{ base_url }/users/#{ params[:id] }/projects"
    end

  end

end
