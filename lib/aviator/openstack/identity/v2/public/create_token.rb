Aviator.define_request :create_token do

  anonymous

  provider      :openstack
  service       :identity
  api_version   :v2
  endpoint_type :public
  
  http_method   :post

  link_to 'documentation',
          'http://docs.openstack.org/api/openstack-identity-service/2.0/content/POST_authenticate_v2.0_tokens_.html'
          
  link_to 'documentation bug',
          'https://bugs.launchpad.net/keystone/+bug/1208607'


  optional_param :username
  optional_param :password
  optional_param :tokenId
  
  optional_param :tenantName
  optional_param :tenantId


  # TODO: Add logic for when session_data is actually an OpenStack
  # authentication response body and not auth bootstrap information
  def url
    url  = session_data[:auth_service][:host_uri]
    url += '/v2.0' if (URI(url).path =~ /^\/?\w+/).nil?
    url += "/tokens"
    
    url
  end


  def body
    p = if params[:tokenId]
          {
            auth: {
              token: {
                id: params[:tokenId]
              }
            }
          }
        else
          {
            auth: {
              passwordCredentials: {
                username: params[:username],
                password: params[:password]
              }
            }
          }
        end
    
    p[:auth][:tenantName] = params[:tenantName] if params[:tenantName]
    p[:auth][:tenantId]   = params[:tenantId]   if params[:tenantId]
    
    p
  end

end
