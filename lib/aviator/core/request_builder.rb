module Aviator

  class BaseRequestNotFoundError < StandardError
    attr_reader :base_request_hierarchy,
                :original_error

    def initialize(base_hierarchy, original_error)
      @base_request_hierarchy = base_hierarchy
      @original_error = original_error
      super("#{ base_request_hierarchy } could not be found!")
    end
  end


  class RequestAlreadyDefinedError < StandardError
    attr_reader :namespace,
                :request_name

    def initialize(namespace, request_name)
      @namespace = namespace
      @request_name = request_name
      super("#{ namespace }::#{ request_name } is already defined")
    end
  end


  class << self

    def define_request(request_name, base_hierarchy=[:request], &block)
      base_klass = base_hierarchy.inject(self) do |namespace, sym|
        begin
          namespace.const_get(sym.to_s.camelize, false)
        rescue NameError => original_error
          raise BaseRequestNotFoundError.new(base_hierarchy, original_error)
        end
      end

      class_obj = Class.new(base_klass, &block)

      set_class_name(
        self,
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

      if hierarchy.empty? && base.const_defined?(const_name, false)
        raise RequestAlreadyDefinedError.new(base, const_name)
      end

      const = if base.const_defined?(const_name, false)
                base.const_get(const_name, false)
              else
                base.const_set(const_name, (hierarchy.empty? ? obj : Module.new))
              end
      
      hierarchy.empty? ? const : set_class_name(const, obj, *hierarchy)
    end
    
  end # class << self

end