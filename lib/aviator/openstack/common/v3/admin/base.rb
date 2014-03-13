module Aviator

  define_request :base, inherit: [:openstack, :common, :v3, :public, :base] do

    meta :endpoint_type, :admin

  end

end
