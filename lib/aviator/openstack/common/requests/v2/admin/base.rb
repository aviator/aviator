module Aviator

  define_request :base, :inherit => [:openstack, :common, :v2, :public, :base] do

    meta :endpoint_type, :admin

  end

end
