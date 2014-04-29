module Aviator

  define_request :validate_token, inherit: [:openstack, :common, :v3, :public, :base] do

    meta :service, :identity
    meta :api_version,   :v3

    link 'documentation',
         'http://api.openstack.org/api-ref-identity-v3.html#Token_Calls'



    #NOT supported at the moment
    param :domainName, required: false, alias: :domain_name
    param :domainId,   required: false, alias: :domain_id

    def headers
      super
    end


    def http_method
      :get
    end


    def url
      "#{ base_url }/auth/tokens" + params_to_querystring(optional_params + required_params)
    end

  end

end
