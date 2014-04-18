module Aviator

  define_request :list_projects, inherit: [:openstack, :common, :v2, :public, :base] do

    meta :service, :identity
    meta :api_version,   :v3

    link 'documentation',
      'http://api.openstack.org/api-ref-identity.html#User_Calls'


    param :id, required: true
    param :page, required: false
    param :per_page, required: false

    def headers
      super
    end


    def http_method
      :get
    end


    def url
      str = "#{ base_url }/projects"
      str += params_to_querystring(optional_params + required_params)
    end

  end

end
