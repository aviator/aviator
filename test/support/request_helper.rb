module Aviator
class Test
  
  module RequestHelper
    
    class << self

      def admin_session_data
        @admin_session_data ||= JSON.parse('{"access": {"token": {"issued_at": "2013-08-26T22:27:13.886315",
          "expires": "2013-08-27T22:27:13Z", "id": "3396443734194600ba8b976415fc8b7a",
          "tenant": {"description": null, "enabled": true, "id": "3cab25130620477b8b03f1bfa8741603",
          "name": "admin"}}, "serviceCatalog": [{"endpoints": [{"adminURL": "http://192.168.56.11:8774/v2/3cab25130620477b8b03f1bfa8741603",
          "region": "RegionOne", "internalURL": "http://192.168.56.11:8774/v2/3cab25130620477b8b03f1bfa8741603",
          "id": "3b72a66bf2f0491bb8dba827cade0d48", "publicURL": "http://192.168.56.11:8774/v2/3cab25130620477b8b03f1bfa8741603"}],
          "endpoints_links": [], "type": "compute", "name": "nova"}, {"endpoints": [{"adminURL":
          "http://192.168.56.11:3333", "region": "RegionOne", "internalURL": "http://192.168.56.11:3333",
          "id": "482f749b370c40eab8788d6d0bc47f48", "publicURL": "http://192.168.56.11:3333"}],
          "endpoints_links": [], "type": "s3", "name": "s3"}, {"endpoints": [{"adminURL":
          "http://192.168.56.11:9292", "region": "RegionOne", "internalURL": "http://192.168.56.11:9292",
          "id": "0cd5d5d5a0c24721a0392b47c89e3640", "publicURL": "http://192.168.56.11:9292"}],
          "endpoints_links": [], "type": "image", "name": "glance"}, {"endpoints": [{"adminURL":
          "http://192.168.56.11:8777", "region": "RegionOne", "internalURL": "http://192.168.56.11:8777",
          "id": "4eb4edec1d2647bfb8ba4f9a5757169d", "publicURL": "http://192.168.56.11:8777"}],
          "endpoints_links": [], "type": "metering", "name": "ceilometer"}, {"endpoints":
          [{"adminURL": "http://192.168.56.11:8776/v1/3cab25130620477b8b03f1bfa8741603",
          "region": "RegionOne", "internalURL": "http://192.168.56.11:8776/v1/3cab25130620477b8b03f1bfa8741603",
          "id": "009e8a41953d439f845b2a0c0dc28b73", "publicURL": "http://192.168.56.11:8776/v1/3cab25130620477b8b03f1bfa8741603"}],
          "endpoints_links": [], "type": "volume", "name": "cinder"}, {"endpoints":
          [{"adminURL": "http://192.168.56.11:8773/services/Admin", "region": "RegionOne",
          "internalURL": "http://192.168.56.11:8773/services/Cloud", "id": "6820836ec6834548bf7b54da0271dded",
          "publicURL": "http://192.168.56.11:8773/services/Cloud"}], "endpoints_links":
          [], "type": "ec2", "name": "ec2"}, {"endpoints": [{"adminURL": "http://192.168.56.11:35357/v2.0",
          "region": "RegionOne", "internalURL": "http://192.168.56.11:5000/v2.0", "id":
          "24a95f51f67949e784971e97463ee4d8", "publicURL": "http://192.168.56.11:5000/v2.0"}],
          "endpoints_links": [], "type": "identity", "name": "keystone"}], "user": {"username":
          "admin", "roles_links": [], "id": "cbbcc4f7aef6435fa2da7e5f0b2f1e97", "roles":
          [{"name": "admin"}], "name": "admin"}, "metadata": {"is_admin": 0, "roles":
          ["01a81f2dbb3441f1aaa8fe68a7c6f546"]}}}').with_indifferent_access
      end


      def admin_bootstrap_session_data
        {
          auth_service: Environment.openstack_admin[:auth_service]
        }
      end

      
      def load_request(*path)
        RequestBuilder.get_request_class(Aviator, path.map{ |el| el.gsub(/\.rb$/, '') })
      end
    
    
      def request_path(*path)
        Pathname.new(__FILE__).join('..', '..', '..', 'lib', 'aviator').expand_path.join(*path)
      end
      
    end
  end
  
end
end