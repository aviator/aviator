require 'pry'
require 'active_support/inflector'

module Aviator

  class << self
    
    def define_request(request_name, &block)
      class_obj = Class.new(Object, &block)
      
      build_or_get_request_class(
        Aviator,
        class_obj,
        
        class_obj.provider,
        class_obj.service,
        class_obj.api_version,
        class_obj.endpoint_type,
        request_name
      )
    end
    
    
    private    
    
    def build_or_get_request_class(base, obj, *hierarchy)
      const_name = hierarchy.shift.to_s.classify

      const = if base.const_defined?(const_name)
                base.const_get(const_name)
              else
                base.const_set(const_name, (hierarchy.empty? ? obj : Module.new))
              end
      
      hierarchy.empty? ? const : build_or_get_request_class(const, obj, *hierarchy)
    end
    
  end # class << self

end # module Aviator

test1 = Aviator.define_request :test1 do
  
  def self.provider
    :openstack
  end
  
  def self.service
    :identity
  end
  
  def self.api_version
    :v2
  end
  
  def self.endpoint_type
    :admin
  end
  
end


test2 = Aviator.define_request :test2 do
  
  def self.provider
    :openstack
  end
  
  def self.service
    :identity
  end
  
  def self.api_version
    :v3
  end
  
  def self.endpoint_type
    :admin
  end
  
end

binding.pry