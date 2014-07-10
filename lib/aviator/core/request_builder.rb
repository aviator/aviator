module Aviator

  class BaseRequestNotFoundError < StandardError
    attr_reader :base_request_hierarchy

    def initialize(base_hierarchy)
      @base_request_hierarchy = base_hierarchy
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


  class RequestBuilder

    class << self

      def define_request(root_namespace, request_name, options, &block)
        base_klass = get_request_class(root_namespace, options[:inherit])

        klass = Class.new(base_klass, &block)

        namespace_arr = [
          klass.provider,
          klass.service,
          'Requests',
          klass.api_version,
          klass.endpoint_type
        ]

        namespace = namespace_arr.inject(root_namespace) do |namespace, sym|
          const_name = sym.to_s.camelize
          namespace.const_set(const_name, Module.new) unless namespace.const_defined?(const_name, false)
          namespace.const_get(const_name, false)
        end

        klassname = request_name.to_s.camelize

        if namespace.const_defined?(klassname, false)
          raise RequestAlreadyDefinedError.new(namespace, klassname)
        end

        namespace.const_set(klassname, klass)
      end


      def get_request_class(root_namespace, request_class_arr)
        provider_specific = request_class_arr != [:request]

        if provider_specific
          full_request_class_arr = request_class_arr.dup
          full_request_class_arr.insert(2, :requests) if provider_specific
        else
          full_request_class_arr = request_class_arr
        end

        full_request_class_arr.inject(root_namespace) do |namespace, sym|
          namespace.const_get(sym.to_s.camelize, false)
        end
      rescue NameError => e
        if Aviator.const_defined?(full_request_class_arr[0].to_s.camelize)
          provider = "Aviator::#{ full_request_class_arr[0] }::Provider".constantize
          arr = ['..'] + full_request_class_arr
          arr[-1,1] = arr.last.to_s + '.rb'
          path = Pathname.new(provider.root_dir).join(*arr.map{|i| i.to_s }).expand_path
        end

        if provider && path.exist?
          require path
          full_request_class_arr.inject(root_namespace) do |namespace, sym|
            namespace.const_get(sym.to_s.camelize, false)
          end
        else
          raise BaseRequestNotFoundError.new(request_class_arr)
        end
      end

    end

  end


  class << self

    def define_request(request_name, options={ :inherit => [:request] }, &block)
      RequestBuilder.define_request self, request_name, options, &block
    end

  end # class << self

end