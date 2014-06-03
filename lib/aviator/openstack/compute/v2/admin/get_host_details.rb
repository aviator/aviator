module Aviator

  define_request :get_host_details, :inherit => [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
      'http://api.openstack.org/api-ref.html#ext-os-hosts'

    param :host_name, :required => true


    def headers
      super
    end


    def http_method
      :get
    end


    def url
      "#{ base_url }/os-hosts/#{ params[:host_name] }"
    end

  end

end
