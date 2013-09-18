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

      namespace_arr = [
        class_obj.provider,
        class_obj.service,
        class_obj.api_version,
        class_obj.endpoint_type
      ]

      namespace = namespace_arr.inject(self) do |namespace, sym|
        const_name = sym.to_s.camelize
        namespace.const_set(const_name, Module.new) unless namespace.const_defined?(const_name, false)
        namespace.const_get(const_name, false)
      end

      request_classname = request_name.to_s.camelize

      if namespace.const_defined?(request_classname, false)
        raise RequestAlreadyDefinedError.new(namespace, request_classname)
      end

      namespace.const_set(request_classname, class_obj)
    end

  end # class << self

end