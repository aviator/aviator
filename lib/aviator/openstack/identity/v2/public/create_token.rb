define_request :create_token do

  anonymous

  endpoint_type :public
  api_version   :v2
  http_method   :post


  required_param :username
  required_param :password
  
  optional_param :tenantName
  optional_param :tenantId


  def path
    'tokens'
  end


  def body
    p = {
      auth: {
        passwordCredentials: {
          username: params[:username],
          password: params[:password]
        }
      }
    }
    
    p[:auth][:tenantName] = params[:tenantName] if params[:tenantName]
    p[:auth][:tenantId]   = params[:tenantId]   if params[:tenantId]
    
    p
  end

end
