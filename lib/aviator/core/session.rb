module Aviator

  class Session

    class EnvironmentNotDefinedError < ArgumentError
      def initialize(path, env)
        super("The environment '#{ env }' is not defined in #{ path }.")
      end
    end


    class InvalidConfigFilePathError < ArgumentError
      def initialize(path)
        super("The config file at #{ path } does not exist!")
      end
    end


    def initialize(opts={})
      config_path = opts[:config_file]
      environment = opts[:environment]

      raise InvalidConfigFilePathError.new(config_path) unless Pathname.new(config_path).file?

      config = YAML.load_file(config_path).with_indifferent_access


      raise EnvironmentNotDefinedError.new(config_path, environment) unless config[environment]

      @environment = config[environment]
    end


    def authenticate(&block)      
      block ||= lambda do |params|
        environment[:auth_credentials].each do |key, value|
          params[key] = value
        end
      end

      response = auth_service.request environment[:auth_service][:request].to_sym, &block
      
      if response.status == 200
        @auth_info = response.body
      else
        raise AuthenticationFailedError.new(response.body)
      end
    end


    def authenticated?
      !auth_info.nil?
    end
    
    
    def method_missing(name, *args, &block)
      service_name_parts = name.to_s.match(/^(\w+)_service$/)
      
      if service_name_parts
        get_service_obj(service_name_parts[1])
      else
        super name, *args, &block
      end
    end
    
    
    private
    
    
    def auth_service
      @auth_service ||= Service.new(
        provider: environment[:provider],
        service:  environment[:auth_service][:name],
        default_session_data: { auth_service: environment[:auth_service] }
      )
    end
    
        
    def environment
      @environment
    end


    def get_service_obj(service_name)
      raise SessionNotAuthenticatedError.new unless self.authenticated?
      
      @services ||= {}
      
      @services[service_name] ||= Service.new(
        provider: environment[:provider],
        service:  service_name,
        default_session_data: auth_info
      )
      
      @services[service_name]
    end
    
    
    def auth_info
      @auth_info
    end
    
  end

end