module Aviator

  define_request :stop_server, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :service, :compute

    link 'documentation',
         'http://developer.openstack.org/api-ref-compute-v2-ext.html#os-server-start-stop'

    param :id, :required => true

    def body
      { 'os-stop' => nil }
    end

    def headers
      super
    end

    def http_method
      :post
    end

    def url
      "#{ base_url }/servers/#{ params[:id] }/action"
    end
  end
end
