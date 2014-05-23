module Aviator

  define_request :list_user_roles_on_domain, inherit: [:openstack, :common, :v3, :public, :base] do

    meta :service, :identity
    meta :api_version,   :v3

    link 'documentation',
      'https://github.com/openstack/identity-api/blob/master/v3/src/markdown/identity-api-v3.md#list-users-roles-on-domain-get-domainsdomain_idusersuser_idroles'

    param :domain_id, required: true
    param :user_id,   required: true


    def headers
      h = {}

      unless self.anonymous?
        h['X-Auth-Token'] = session_data.token
      end

      h
    end


    def http_method
      :get
    end


    def url
      p = params
      "#{ base_url }/domains/#{ params[:domain_id] }/users/#{ params[:user_id] }/roles"
    end

  end

end