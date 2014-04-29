module Aviator

  define_request :create_token, inherit: [:openstack, :common, :v3, :public, :base] do

    meta :anonymous, true
    meta :service, :identity
    meta :api_version,   :v3

    link 'documentation',
         'http://api.openstack.org/api-ref-identity-v3.html#Token_Calls'

    param :userId,     required: false, alias: :user_id
    param :username,   required: false
    param :password,   required: false
    param :tokenId,    required: false, alias: :token_id
    param :tenantName, required: false, alias: :tenant_name
    param :tenantId,   required: false, alias: :tenant_id

    #NOT supported at the moment
    param :domainName, required: false, alias: :domain_name
    param :domainId,   required: false, alias: :domain_id

    def body
      params[:tokenId] ? token_auth(params) : password_auth(params)
    end

    def http_method
      :post
    end

    def url
      url  = session_data[:auth_service][:host_uri]
      url += '/v3' if (URI(url).path =~ /^\/?\w+/).nil?
      url += "/auth/tokens"
    end

    private
    def token_auth(local_params)
      p = {
        auth: {
          identity: {
            methods: ['token']
          },
          token: {
            id: local_params[:tokenId]
          }
        }
      }
      p[:auth][:scope] = scope_object(local_params) if local_params[:tenantName] || local_params[:tenantId]
      p
    end

    def password_auth(local_params)
      p = {
        auth: {
          identity: {
            methods: ['password'],
            password: {
              user: user_object(params)
            }
          }

        }
      }

      if local_params[:domainName] || local_params[:domainId]
        p[:auth][:identity][:password][:user][:domain] = domain_object(params)
      end

      if local_params[:tenantName] || local_params[:tenantId] || local_params[:domainName] || local_params[:domainId]
        p[:auth][:scope] = scope_object(local_params)
      end
      p
    end

    def scope_object(local_params)
      p = {}
      if local_params[:tenantName] || local_params[:tenantId]
        p = {project: project_object(local_params)}
        p[:project][:domain] = domain_object(local_params) if local_params[:domainName] || local_params[:domainId]
      elsif local_params[:domainName] || local_params[:domainId]
        p = {domain: domain_object(local_params)}
      end
      p
    end

    def domain_object(local_params)
      compact_hash({
        id: local_params[:domainId],
        name: local_params[:domainName]
      })
    end

    def project_object(local_params)
      compact_hash({
        id: local_params[:tenantId],
        name: local_params[:tenantName]
      })
    end

    def user_object(local_params)
      compact_hash({
        id: local_params[:userId],
        name: local_params[:username],
        password: local_params[:password]
      })
    end

    def compact_hash(hash, opts = {})
      opts[:recurse] = true if opts[:recurse].nil?
      hash.inject({}) do |new_hash, (k,v)|
        if !v.nil?
          new_hash[k] = opts[:recurse] && v.kind_of?(Hash) ? compact_hash(v, opts) : v
        end
        new_hash
      end
    end

  end

end
