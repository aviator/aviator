module Aviator

  class << self
    
    def define_request(request_name, &block)
      class_obj = Class.new(Request, &block)
      
      set_class_name(
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
    
    def set_class_name(base, obj, *hierarchy)
      const_name = hierarchy.shift.to_s.camelize

      const = if base.const_defined?(const_name, false)
                base.const_get(const_name, false)
              else
                base.const_set(const_name, (hierarchy.empty? ? obj : Module.new))
              end
      
      hierarchy.empty? ? const : set_class_name(const, obj, *hierarchy)
    end
    
  end # class << self

end