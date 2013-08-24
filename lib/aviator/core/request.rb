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


    def initialize(params={})
      validate_params(params)
      @params = params
    end


    def anonymous?
      self.class.anonymous?
    end


    def api_version
      self.class.api_version
    end


    def body?
      self.respond_to? :body
    end


    def endpoint_type
      self.class.endpoint_type
    end


    def http_method
      self.class.http_method
    end
    
    
    def path?
      self.respond_to? :path
    end


    def querystring?
      respond_to? :querystring
    end


    private


    def params
      @params.dup
    end


    def validate_params(params)
      validators = methods.select{ |name| name =~ /^param_validator_/ }
      validators.each do |name|
        send(name, params)
      end
    end


    class << self

      def anonymous
        # @anonymous will be defined by the descendant class
        # where this method (or macro) is called.
        @anonymous = true
      end


      def anonymous?
        # @anonymous will be defined by the descendant class
        @anonymous == true
      end


      def api_version(value=nil)
        if value
          # @api_version will be defined by the descendant
          # class where this method is called.
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
          # @endpoint_type will be defined by the descendant
          # class where this method is called.
          @endpoint_type = value
        else
          @endpoint_type
        end
      end


      def http_method(value=nil)
        if value
          # @http_method will be defined by the descendant
          # class where this method is called.
          @http_method = value
        else
          @http_method
        end
      end


      def path?
        instance_methods.include? :path
      end
      

      private


      def requires_param(param_name)
        last_num = instance_methods.map{|n| n.to_s.gsub(/^param_validator_/, '').to_i }.max

        define_method "param_validator_#{ last_num + 1 }".to_sym, lambda { |params|
          raise ArgumentError.new("Missing parameter #{ param_name }.") unless params.keys.include? param_name
        }
      end

    end

  end

end