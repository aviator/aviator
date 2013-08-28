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


    def authenticate(opts={}, &block)
      key_name = opts[:key_name] || default_key_name
      
      # This lambda is a candidate for extraction to aviator/openstack
      block ||= lambda do |params|
        credentials = environment[:auth_credentials]

        params[:username]   = credentials[:username]
        params[:password]   = credentials[:password]
        params[:tenantName] = credentials[:tenantName] if credentials[:tenantName]
      end

      response = auth_service.request environment[:auth_service][:request].to_sym, &block
      
      if response.status == 200
        keychain[key_name] = response.body
      else
        raise AuthenticationFailedError.new(response.body)
      end
    end


    def authenticated?
      !keychain[default_key_name].nil?
    end
    
    
    private
    
    
    def auth_service
      @auth_service ||= Service.new(
        provider: environment[:provider],
        service:  environment[:auth_service][:name],
        default_session_data: { auth_service: environment[:auth_service] }
      )
    end
    
    
    def default_key_name
      @default_key_name ||= :default
    end
    
    
    def default_key_name=(val)
      @default_key_name = val
    end
    
    
    def environment
      @environment
    end
    
    
    def keychain
      @keychain ||= HashWithIndifferentAccess.new
    end

  end

end