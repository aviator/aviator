module Aviator

  class Request

    class ApiVersionNotDefinedError < StandardError
      def initialize
        super "api_version is not defined."
      end
    end

    class EndpointTypeNotDefinedError < StandardError
      def initialize
        super "endpoint_type is not defined."
      end
    end

    class PathNotDefinedError < StandardError
      def initialize
        super "path is not defined."
      end
    end


    def initialize(session_data=nil)
      @session_data = session_data

      params = self.class.params_class.new if self.class.params_class

      if params
        yield(params) if block_given?
        validate_params(params)
      end

      @params = params
    end


    def anonymous?
      self.class.anonymous?
    end


    def body?
      self.class.body?
    end


    def headers?
      self.class.headers?
    end


    def links
      self.class.links
    end


    def optional_params
      self.class.optional_params
    end


    def params
      @params.dup
    end


    def required_params
      self.class.required_params
    end


    def session_data
      @session_data
    end


    def session_data?
      !session_data.nil?
    end


    def querystring?
      self.class.querystring?
    end


    def url?
      self.class.url?
    end


    private


    def validate_params(params)
      required_params = self.class.required_params

      required_params.each do |name|
        raise ArgumentError.new("Missing parameter #{ name }.") if params.send(name).nil?
      end
    end


    # NOTE that, because we are defining the following as class methods, when they
    # are called, all 'instance' variables are actually defined in the descendant class,
    # not in the instance/object. This is by design since we want to keep these attributes
    # within the class and because they don't change between instances anyway.
    class << self

      def anonymous?
        respond_to?(:anonymous) && anonymous == true
      end


      def body?
        instance_methods.include? :body
      end


      def headers?
        instance_methods.include? :headers
      end


      def links
        @links ||= []
      end


      def param_aliases
        @param_aliases ||= {}
      end


      def params_class
        all_params = required_params + optional_params

        if all_params.length > 0 && @params_class.nil?
          @params_class = build_params_class(all_params, self.param_aliases)
        end

        @params_class
      end


      def optional_params
        @optional_params ||= []
      end


      def querystring?
        instance_methods.include? :querystring
      end


      def required_params
        @required_params ||= []
      end


      def url?
        instance_methods.include? :url
      end


      private


      def build_params_class(all_params, param_aliases)
        Struct.new(*all_params) do
          alias :param_getter :[]
          alias :param_setter :[]=

          define_method :[] do |key|
            key = param_aliases[key.to_sym] if param_aliases.keys.include? key.to_sym
            param_getter(key)
          end

          define_method :[]= do |key, value|
            key = param_aliases[key.to_sym] if param_aliases.keys.include? key.to_sym
            param_setter(key, value)
          end

          param_aliases.each do |param_alias, param_name|
            define_method param_alias do
              param_getter(param_name)
            end

            define_method "#{ param_alias }=" do |value|
              param_setter(param_name, value)
            end
          end
        end
      end


      def link(rel, href)
        links << { :rel => rel, :href => href }
      end


      def meta(attr_name, attr_value)
        eigenclass = class << self; self; end
        eigenclass.send(:define_method, attr_name) do
          attr_value
        end

        define_method(attr_name) do
          self.class.send(attr_name)
        end
      end


      def param(param_name, opts={})
        opts  = Hashish.new(opts)
        list  = (opts[:required] == false ? optional_params : required_params)
        list << param_name unless optional_params.include?(param_name)

        if opts[:alias]
          self.param_aliases[opts[:alias]] = param_name
        end
      end

    end

  end

end
