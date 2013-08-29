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


    def api_version
      self.class.api_version
    end


    def body?
      self.class.body?
    end


    def endpoint_type
      self.class.endpoint_type
    end


    def headers?
      self.class.headers?
    end


    def http_method
      self.class.http_method
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


    def querystring?
      self.class.querystring?
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

      def anonymous
        @anonymous = true
      end


      def anonymous?
        @anonymous == true
      end


      def api_version(value=nil)
        if value
          @api_version = value
        else
          @api_version
        end
      end


      def body?
        instance_methods.include? :body
      end


      def endpoint_type(value=nil)
        if value
          @endpoint_type = value
        else
          @endpoint_type
        end
      end


      def headers?
        instance_methods.include? :headers
      end


      def http_method(value=nil)
        if value
          @http_method = value
        else
          @http_method
        end
      end
      
      
      def link_to(rel, href)
        links << { rel: rel, href: href }
      end
      
      
      def links
        @links ||= []
      end


      def params_class
        all_params = required_params + optional_params

        if all_params.length > 0
          @params_class ||= Struct.new(*all_params)
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

      def required_param(param_name)
        required_params << param_name unless required_params.include?(param_name)
      end


      def optional_param(param_name)
        optional_params << param_name unless optional_params.include?(param_name)
      end

    end

  end

end