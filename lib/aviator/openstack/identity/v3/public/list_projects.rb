module Aviator

  define_request :list_projects, inherit: [:openstack, :common, :v3, :public, :base] do

    meta :service, :identity

    link 'documentation',
      'http://api.openstack.org/api-ref-identity-v3.html#Project_Calls'

    param :page, required: false
    param :per_page, required: false
    param :domain_id, required: false
    param :name, required: false
    param :enabled, required: false

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
