module Aviator

  define_request :base, :inherit => [:openstack, :common, :v0, :public, :base] do

    meta :api_version,   :v3

  end

end
