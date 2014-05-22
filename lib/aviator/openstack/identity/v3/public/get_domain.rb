module Aviator

  define_request :get_domain, inherit: [:openstack, :common, :v3, :public, :base] do

    meta :service, :identity
    meta :api_version,   :v3

    link 'documentation',
      'http://developer.openstack.org/api-ref-identity-v3.html#domains-v3'


    param :id, required: true

    def headers
      super
    end


    def http_method
      :get
    end


    def url
      "#{ base_url }/domains/#{ params[:id] }/"
    end

  end

end