module Aviator

  define_request :authenticate, :inherit => [:dummy, :common, :v0, :public, :base] do

    meta :anonymous,   true
    meta :service,     :auth
    meta :api_version, :v1

    link 'documentation', 'http://doc.dummyapi.org/dummy.html'

    param :username, :required => true
    param :password, :required => true

    def body
      {
        :username => params[:username],
        :password => params[:password]
      }
    end


    def http_method
      :post
    end


    def url
      "#{base_url}/authenticate"
    end

  end

end
