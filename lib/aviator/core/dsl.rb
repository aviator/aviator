module Aviator

  class << self
    
    def define_request(request_name, &block)
      class_obj = Class.new(Request, &block)
      
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
      const_name = hierarchy.shift.to_s.camelize

      const = if base.const_defined?(const_name)
                base.const_get(const_name)
              else
                base.const_set(const_name, (hierarchy.empty? ? obj : Module.new))
              end
      
      hierarchy.empty? ? const : build_or_get_request_class(const, obj, *hierarchy)
    end
    
  end # class << self

end # module Aviator