module Aviator

  define_request :list_domains, inherit: [:openstack, :common, :v3, :public, :base] do

    meta :service,      :identity
    meta :api_version,  :v3

    link 'documentation',
      'http://developer.openstack.org/api-ref-identity-v3.html#domains-v3'

    link 'documentation',
      'https://github.com/openstack/identity-api/blob/master/v3/src/markdown/identity-api-v3.md#list-domains-get-domains'

    param :page,      required: false
    param :per_page,  required: false
    param :name,      required: false
    param :enabled,   required: false

    def headers
      super
    end


    def http_method
      :get
    end

    def url
      str = "#{ base_url }/domains"
      str += params_to_querystring(optional_params)
    end

  end

end
