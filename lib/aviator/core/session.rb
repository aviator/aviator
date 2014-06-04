module Aviator

  class Session

    class AuthenticationError < StandardError
      def initialize(last_auth_body)
        super("Authentication failed. The server returned #{ last_auth_body }")
      end
    end


    class EnvironmentNotDefinedError < ArgumentError
      def initialize(path, env)
        super("The environment '#{ env }' is not defined in #{ path }.")
      end
    end

    class InitializationError < StandardError
      def initialize
        super("The session could not find :session_dump, :config_file, and " \
              ":config in the constructor arguments provided")
      end
    end

    class InvalidConfigFilePathError < ArgumentError
      def initialize(path)
        super("The config file at #{ path } does not exist!")
      end
    end


    class NotAuthenticatedError < StandardError
      def initialize
        super("Session is not authenticated. Please authenticate before proceeding.")
      end
    end


    class ValidatorNotDefinedError < StandardError
      def initialize
        super("The validator request name is not defined for this session object.")
      end
    end


    def initialize(opts={})
      if opts.has_key? :session_dump
        initialize_with_dump(opts[:session_dump])
      elsif opts.has_key? :config_file
        initialize_with_config(opts[:config_file], opts[:environment])
      elsif opts.has_key? :config
        initialize_with_hash(opts[:config])
      else
        raise InitializationError.new
      end

      @log_file = opts[:log_file]
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
        update_services_session_data
      else
        raise AuthenticationError.new(response.body)
      end
    end


    def authenticated?
      !auth_info.nil?
    end


    def dump
      JSON.generate({
        :environment => environment,
        :auth_info   => auth_info
      })
    end


    def load(session_dump)
      initialize_with_dump(session_dump)
      update_services_session_data
      self
    end


    def method_missing(name, *args, &block)
      service_name_parts = name.to_s.match(/^(\w+)_service$/)

      if service_name_parts
        get_service_obj(service_name_parts[1])
      else
        super name, *args, &block
      end
    end


    def self.load(session_dump, opts={})
      opts[:session_dump] = session_dump

      new(opts)
    end


    def validate
      raise NotAuthenticatedError.new unless authenticated?
      raise ValidatorNotDefinedError.new unless environment[:auth_service][:validator]

      auth_with_bootstrap = auth_info.merge({ :auth_service => environment[:auth_service] })

      response = auth_service.request environment[:auth_service][:validator].to_sym, :session_data => auth_with_bootstrap

      response.status == 200 || response.status == 203
    end


    private


    def auth_info
      @auth_info
    end


    def auth_service
      @auth_service ||= Service.new(
        :provider => environment[:provider],
        :service  => environment[:auth_service][:name],
        :default_session_data => { :auth_service => environment[:auth_service] },
        :log_file => log_file
      )
    end


    def environment
      @environment
    end


    def get_service_obj(service_name)
      raise NotAuthenticatedError.new unless self.authenticated?

      @services ||= {}

      @services[service_name] ||= Service.new(
        :provider => environment[:provider],
        :service  => service_name,
        :default_session_data => auth_info,
        :log_file => log_file
      )

      @services[service_name]
    end


    def initialize_with_config(config_path, environment)
      raise InvalidConfigFilePathError.new(config_path) unless Pathname.new(config_path).file?

      config = Hashish.new(YAML.load_file(config_path))

      raise EnvironmentNotDefinedError.new(config_path, environment) unless config[environment]

      @environment = config[environment]
    end


    def initialize_with_dump(session_dump)
      session_info = Hashish.new(JSON.parse(session_dump))
      @environment = session_info[:environment]
      @auth_info   = session_info[:auth_info]
    end

    def initialize_with_hash(hash_obj)
      @environment = Hashish.new(hash_obj)
    end

    def log_file
      @log_file
    end


    def update_services_session_data
      return unless @services

      @services.each do |name, obj|
        obj.default_session_data = auth_info
      end
    end

  end

end
