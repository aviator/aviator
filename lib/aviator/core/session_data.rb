module Aviator

  class SessionData < HashWithIndifferentAccess

    class << self

      def from_response(response)
        body = response.body
        headers = response.headers
        from_body_and_headers(body, headers)
      end

      def from_body_and_headers(body, headers = {})
        if body["access"]
          from_keystone_v2(body, headers)
        else
          from_keystone_v3(body, headers)
        end
      end

      def from_body(body)
        from_body_and_headers(body, {})
      end

      def from_keystone_v2(body, headers = {})
        new(:token => body['access']["token"]["id"], :catalog => body["access"]["serviceCatalog"], :user => body["access"]["user"], :expiry => body['access']["token"]["expires"], :project => body['access']['token']['tenant'])
      end

      def from_keystone_v3(body, headers = {})
        token = body[:token]
        new(:token => headers['x-subject-token'], :catalog => token["catalog"], :user => token["user"], :expiry => token["expires_at"], :domain => token['domain'], :extra => token['extra'], :roles => token["roles"])
      end

      def from_hash(hash)
        h = hash.with_indifferent_access
        new(:token => h[:token], :catalog => h[:catalog], :user => h[:user], :expiry => h[:expiry], :project => h[:project])
      end

    end

    [:user, :token, :project, :catalog, :expiry].each do |attr|
      define_method(attr.to_sym) do
        self[attr.to_sym]
      end

      define_method("#{attr}=".to_sym) do |v|
        self[attr.to_sym] = v
      end
    end

    def [](k)
      v = super(k)
      case k.to_s
      when 'catalog'
        if v.first && v.first['endpoints'].first.has_key?('publicURL')
          normalize_v2_catalogs(v)
        else
          normalize_v3_catalogs(v)
        end
      else
        v
      end
    end

    private
    def normalize_v3_catalogs(v)
      v
    end

    def normalize_v2_catalogs(v)
      v.map do |catalog|
        normalize_v2_catalog(catalog)
      end
    end

    def normalize_v2_catalog(catalog)
      {
        'type' => catalog[:type],
        # 'id' => catalog[:id],
        'name'=> catalog[:name],
        'endpoints' =>normalize_v2_endpoints(catalog[:endpoints].first)
      }.with_indifferent_access
    end

    def normalize_v2_endpoints(endpoint)
      [:admin, :public, :internal].map do |interface|
        {
          :interface => interface.to_s,
          :url => endpoint["#{interface}URL".to_sym],
          :reigion => endpoint[:region]
        }.with_indifferent_access
      end
    end

  end
end