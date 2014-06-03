module Aviator

  define_request :create_token, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :anonymous, true
    meta :service,   :identity

    link 'documentation',
         'http://docs.openstack.org/api/openstack-identity-service/2.0/content/POST_authenticate_v2.0_tokens_.html'

    link 'documentation bug',
         'https://bugs.launchpad.net/keystone/+bug/1208607'


    param :username,   :required => false
    param :password,   :required => false
    param :tokenId,    :required => false, :alias => :token_id
    param :tenantName, :required => false, :alias => :tenant_name
    param :tenantId,   :required => false, :alias => :tenant_id


    def body
      p = if params[:tokenId]
            {
              :auth => {
                :token => {
                  :id => params[:tokenId]
                }
              }
            }
          else
            {
              :auth => {
                :passwordCredentials => {
                  :username => params[:username],
                  :password => params[:password]
                }
              }
            }
          end

      p[:auth][:tenantName] = params[:tenantName] if params[:tenantName]
      p[:auth][:tenantId]   = params[:tenantId]   if params[:tenantId]

      p
    end


    def http_method
      :post
    end


    def url
      url  = session_data[:auth_service][:host_uri]
      url += '/v2.0' if (URI(url).path =~ /^\/?\w+/).nil?
      url += "/tokens"
    end

  end

end