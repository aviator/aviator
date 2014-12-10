module Aviator
  # Original work by Stephen Paul Suarez
  # https://github.com/musashi-dev/aviator/blob/develop/lib/aviator/openstack/identity/v3/public/create_token.rb

  define_request :create_token, :inherit => [:openstack, :common, :v3, :public, :base] do

    meta :anonymous,   true
    meta :service,     :identity
    meta :api_version, :v3

    link 'documentation',
         'http://api.openstack.org/api-ref-identity-v3.html#Token_Calls'

    param :domainId,   :required => false, :alias => :domain_id
    param :domainName, :required => false, :alias => :domain_name
    param :password,   :required => false
    param :tenantId,   :required => false, :alias => :tenant_id
    param :tenantName, :required => false, :alias => :tenant_name
    param :tokenId,    :required => false, :alias => :token_id
    param :userId,     :required => false, :alias => :user_id
    param :username,   :required => false


    def body
      params[:token_id] ? token_auth_body : password_auth_body
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

    # Removes nil elements from hash
    # Adapted from http://stackoverflow.com/a/14773555/402145
    def compact_hash(hash, opts = {})
      opts[:recurse] ||= true
      hash.inject({}) do |new_hash, (k,v)|
        if !v.nil?
          new_hash[k] = opts[:recurse] && v.kind_of?(Hash) ? compact_hash(v, opts) : v
        end
        new_hash
      end
    end


    def domain_hash
      compact_hash({
        :id   => params[:domain_id],
        :name => params[:domain_name]
      })
    end


    def password_auth_body
      p = {
        :auth => {
          :identity => {
            :methods  => ['password'],
            :password => {
              :user => compact_hash({
                         :id       => params[:user_id],
                         :name     => params[:username],
                         :password => params[:password]
                       })
            }
          }
        }
      }

      if params[:domain_name] || params[:domain_id]
        p[:auth][:identity][:password][:user][:domain] = domain_hash
      end

      if params[:tenant_name] || params[:tenant_id] || params[:domain_name] || params[:domain_id]
        p[:auth][:scope] = scope_hash
      end
      p
    end


    def scope_hash
      p = {}

      if params[:tenant_name] || params[:tenant_id]
        p[:project] = compact_hash({
                        :id   => params[:tenant_id],
                        :name => params[:tenant_name]
                      })
        p[:project][:domain] = domain_hash if params[:domain_name] || params[:domain_id]

      elsif params[:domain_name] || params[:domain_id]
        p[:domain] = domain_hash
      end

      p
    end


    def token_auth_body
      p = {
        :auth => {
          :identity => {
            :methods => ['token'],
            :token   => { :id => params[:token_id] }
          }
        }
      }
      p[:auth][:scope] = scope_hash if params[:tenant_name] || params[:tenant_id]
      p
    end


  end

end
