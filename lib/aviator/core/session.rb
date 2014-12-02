module Aviator

  #
  # Manages a provider (e.g. OpenStack) session.
  #
  # Author::    Mark Maglana (mmaglana@gmail.com)
  # Copyright:: Copyright (c) 2014 Mark Maglana
  # License::   Distributed under the MIT license
  # Homepage::  http://aviator.github.io/www/
  #
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

    #
    # Create a new Session instance with options provided in <tt>opts</tt> which can
    # have many forms discussed below.
    #
    # <b>Initialize with a config file</b>
    #
    #  Aviator::Session.new(:config_file => 'path/to/aviator.yml', :environment => :production)
    #
    # In the above example, the config file must have the following form:
    #
    #  production:
    #    provider: openstack
    #    auth_service:
    #      name: identity
    #      host_uri: 'http://my.openstackenv.org:5000'
    #      request: create_token
    #      validator: list_tenants
    #      api_version: v2
    #    auth_credentials:
    #      username: myusername
    #      password: mypassword
    #      tenant_name: myproject
    #
    # Once the session has been instantiated, you may authenticate against the
    # provider as follows:
    #
    #  session.authenticate
    #
    # Note that the required items under <tt>auth_credentials</tt> in the config
    # file depends on the required parameters of the request class declared under
    # <tt>auth_service</tt>. If writing the <tt>auth_credentials</tt> in the config
    # file is not acceptable, you may omit it and just supply the credentials at
    # runtime. For instance, assume that the <tt>auth_credentials</tt> section in the
    # config file above is missing. You would then authenticate as follows:
    #
    #  session.authenticate do |params|
    #    params.username    = ARGV[0]
    #    params.password    = ARGV[1]
    #    params.tenant_name = ARGV[2]
    #  end
    #
    # Please see Session#authenticate for more info.
    #
    # Note that while the example config file above only has one environment (production),
    # you can declare an arbitrary number of environments in your config file. Shifting
    # between environments is as simple as changing the <tt>:environment</tt> to refer to that.
    #
    #
    # <b>Initialize with an in-memory hash</b>
    #
    # You can create an in-memory hash which is similar in structure to the config file except
    # that you don't need to specify an environment name. For example:
    #
    #  configuration = {
    #    :provider => 'openstack',
    #    :auth_service => {
    #      :name      => 'identity',
    #      :host_uri  => 'http://devstack:5000/v2.0',
    #      :request   => 'create_token',
    #      :validator => 'list_tenants'
    #    }
    #  }
    #
    # Supply this to the initializer using the <tt>:config</tt> option. For example:
    #
    #  Aviator::Session.new(:config => configuration)
    #
    #
    # <b>Initialize with a session dump</b>
    #
    # You can create a new Session instance using a dump from another instance. For example:
    #
    #  session_dump = session1.dump
    #  session2 = Aviator::Session.new(:session_dump => session_dump)
    #
    # However, Session.load is cleaner and recommended over this method.
    #
    #
    # <b>Optionally supply a log file</b>
    #
    # In all forms above, you may optionally add a <tt>:log_file</tt> option to make
    # Aviator write all HTTP calls to the given path. For example:
    #
    #  Aviator::Session.new(:config_file => 'path/to/aviator.yml', :environment => :production, :log_file => 'path/to/log')
    #
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

    #
    # Authenticates against the auth_service request class declared in the session's
    # configuration during initialization. Please see Session.new for more information
    # on declaring the request class to use for authentication.
    #
    # If the auth_service request class accepts a parameter block, you may also supply that
    # when calling this method and it will be directly passed to the request. For example:
    #
    #  session = Aviator::Session.new(:config => config)
    #  session.authenticate do |params|
    #    params.username    = username
    #    params.password    = password
    #    params.tenant_name = project
    #  end
    #
    # Expects an HTTP status 200 or 201. Any other status is treated as a failure.
    #
    # Note that you can also treat the block's argument like a hash with the attribute
    # names as the keys. For example, we can rewrite the above as:
    #
    #  session = Aviator::Session.new(:config => config)
    #  session.authenticate do |params|
    #    params[:username]    = username
    #    params[:password]    = password
    #    params[:tenant_name] = project
    #  end
    #
    # Keys can be symbols or strings.
    #
    def authenticate(&block)
      block ||= lambda do |params|
        config[:auth_credentials].each do |key, value|
          begin
            params[key] = value
          rescue NameError => e
            raise NameError.new("Unknown param name '#{key}'")
          end
        end
      end

      response = auth_service.request config[:auth_service][:request].to_sym, &block

      if [200, 201].include? response.status
        @auth_response = Hashish.new({
          :headers => response.headers,
          :body    => response.body
        })
        update_services_session_data
      else
        raise AuthenticationError.new(response.body)
      end
      self
    end

    #
    # Returns true if the session has been authenticated.
    #
    def authenticated?
      !auth_response.nil?
    end

    #
    # Returns its configuration.
    #
    def config
      @config
    end

    #
    # Returns a JSON string of its configuration and auth_data. This string can be streamed
    # or stored and later re-loaded in another Session instance. For example:
    #
    #  session = Aviator::Session.new(:config => configuration)
    #  str = session.dump
    #
    #  # time passes...
    #
    #  session = Aviator::Session.load(str)
    #
    def dump
      JSON.generate({
        :config        => config,
        :auth_response => auth_response
      })
    end


    #
    # Same as Session::load but re-uses the Session instance this method is
    # called on instead of creating a new one.
    #
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


    #
    # Creates a new Session object from a previous session's dump. See Session#dump for
    # more information.
    #
    # If you want the newly deserialized session to log its output, make sure to indicate it on load
    #
    #  Aviator::Session.load(session_dump_str, :log_file => 'path/to/aviator.log')
    #
    def self.load(session_dump, opts={})
      opts[:session_dump] = session_dump

      new(opts)
    end


    #
    # Returns the log file path. May be nil if none was provided during initialization.
    #
    def log_file
      @log_file
    end


    #
    # Calls the given request of the given service. An example call might look like:
    #
    #  session.request :compute_service, :create_server do |p|
    #    p.name       = "My Server"
    #    p.image_ref  = "7cae8c8e-fb01-4a88-bba3-ae0fcb1dbe29"
    #    p.flavor_ref = "fa283da1-59a5-4245-8569-b6eadf69f10b"
    #  end
    #
    # Note that you can also treat the block's argument like a hash with the attribute
    # names as the keys. For example, we can rewrite the above as:
    #
    #  session.request :compute_service, :create_server do |p|
    #    p[:name]       = "My Server"
    #    p[:image_ref]  = "7cae8c8e-fb01-4a88-bba3-ae0fcb1dbe29"
    #    p[:flavor_ref] = "fa283da1-59a5-4245-8569-b6eadf69f10b"
    #  end
    #
    # Keys can be symbols or strings.
    #
    # ---
    #
    # <b>Request Options</b>
    #
    # You can further customize how the request is fulfilled by providing one or more
    # options to the method call. For example, the following ensures that the request
    # will call the :create_server request for the v1 API.
    #
    #  session.request :compute_service, :create_server, :api_version => v1
    #
    # The available options vary depending on the provider. See the documentation
    # on the provider's Provider class for more information (e.g. Aviator::OpenStack::Provider)
    #
    def request(service_name, request_name, opts={}, &params)
      service = send("#{service_name.to_s}_service")
      service.request(request_name, opts, &params)
    end


    #
    # Returns true if the session is still valid in the underlying provider. This method does this
    # by calling the validator request class declared declared under <tt>auth_service</tt> in the
    # configuration. The validator can be any request class as long as:
    #
    # * The request class exists!
    # * Does not require any parameters
    # * It returns an HTTP status 200 or 203 to indicate auth info validity.
    # * It returns any other HTTP status to indicate that the auth info is invalid.
    #
    # See Session::new for an example on how to specify the request class to use for session validation.
    #
    def validate
      raise NotAuthenticatedError.new unless authenticated?
      raise ValidatorNotDefinedError.new unless config[:auth_service][:validator]

      auth_with_bootstrap = auth_response.merge({ :auth_service  => config[:auth_service] })

      response = auth_service.request config[:auth_service][:validator].to_sym, :session_data => auth_with_bootstrap
      response.status == 200 || response.status == 203
    end


    private


    def auth_response
      @auth_response
    end


    def auth_service
      @auth_service ||= Service.new(
        :provider             => config[:provider],
        :service              => config[:auth_service][:name],
        :default_session_data => { :auth_service => config[:auth_service] },
        :log_file             => log_file
      )
    end


    def get_service_obj(service_name)
      @services ||= {}

      if @services[service_name].nil?
        default_options = config["#{ service_name }_service"]

        @services[service_name] = Service.new(
          :provider             => config[:provider],
          :service              => service_name,
          :default_session_data => auth_response,
          :default_options      => default_options,
          :log_file             => log_file
        )
      end

      @services[service_name]
    end


    def initialize_with_config(config_path, environment)
      raise InvalidConfigFilePathError.new(config_path) unless Pathname.new(config_path).file?

      all_config = Hashish.new(YAML.load_file(config_path))

      raise EnvironmentNotDefinedError.new(config_path, environment) unless all_config[environment]

      @config = all_config[environment]
    end


    def initialize_with_dump(session_dump)
      session_info   = Hashish.new(JSON.parse(session_dump))
      @config        = session_info[:config]
      @auth_response = session_info[:auth_response]
    end


    def initialize_with_hash(hash_obj)
      @config = Hashish.new(hash_obj)
    end


    def update_services_session_data
      return unless @services

      @services.each do |name, obj|
        obj.default_session_data = auth_response
      end
    end

  end

end
