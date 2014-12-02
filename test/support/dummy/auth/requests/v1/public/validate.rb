module Aviator

  define_request :validate, :inherit => [:dummy, :common, :v0, :public, :base] do

    meta :anonymous,   false
    meta :service,     :auth
    meta :api_version, :v1

    link 'documentation', 'http://doc.dummyapi.org/dummy.html'

    def http_method
      :post
    end


    def url
      "#{base_url}/validate"
    end

  end

end
