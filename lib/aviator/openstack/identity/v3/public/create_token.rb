module Aviator

  define_request :create_token, inherit: [:openstack, :common, :v2, :public, :base] do

    meta :anonymous, true
    meta :service, :identity
    meta :api_version,   :v3

    link 'documentation',
         'http://docs.openstack.org/api/openstack-identity-service/2.0/content/POST_authenticate_v2.0_tokens_.html'

    link 'documentation bug',
         'https://bugs.launchpad.net/keystone/+bug/1208607'


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
      p = params[:tokenId] ? token_auth(params) : password_auth(params)
      puts p
      p
    end

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
      p[:auth][:scope] = scope(local_params) if local_params[:tenantName] || local_params[:tenantId]
      p
    end

    def password_auth(local_params)
      p = {
        auth: {
          identity: {
            methods: ['password'],
            password: {
              user: {
                password: local_params[:password]
              }
            }
          }

        }
      }

      p[:auth][:identity][:password][:user][:name] =  local_params[:username] if local_params[:username]
      #p[:auth][:identity][:password][:user][:password] = local_params[:password] if local_params[:password]
      p[:auth][:identity][:password][:user][:id] = local_params[:userId] if local_params[:userId]

      if local_params[:domainName] || local_params[:domainId]
        p[:auth][:identity][:password][:user][:domain] = {}
        p[:auth][:identity][:password][:user][:domain][:id] = local_params[:domainId] if local_params[:domainId]
        p[:auth][:identity][:password][:user][:domain][:name] = local_params[:domainName] if local_params[:domainName]
      end

      if local_params[:tenantName] || local_params[:tenantId] || local_params[:domainName] || local_params[:domainId]
        p[:auth][:scope] = scope(local_params)
      end
      p
    end


    def scope(local_params)
      p = {}
      if local_params[:tenantName] || local_params[:tenantId]
        p = {project: {}}
        p[:project][:name] = local_params[:tenantName] if local_params[:tenantName]
        p[:project][:id] = local_params[:tenantId] if local_params[:tenantId]
        if local_params[:domainName] || local_params[:domainId]
          p[:project][:domain] = {}
          p[:project][:domain][:id] = local_params[:domainId] if local_params[:domainId]
          p[:project][:domain][:name] = local_params[:domainName] if local_params[:domainName]
        end
      elsif local_params[:domainName] || local_params[:domainId]
        p = {domain: {}}
        p[:domain][:id] = local_params[:domainId] if local_params[:domainId]
        p[:domain][:name] = local_params[:domainName] if local_params[:domainName]
      end
      p
    end

    def domain_object(local_params)


    end

    def http_method
      :post
    end


    def url
      url  = session_data[:auth_service][:host_uri]
      url += '/v3' if (URI(url).path =~ /^\/?\w+/).nil?
      url += "/auth/tokens"
    end

  end

end
