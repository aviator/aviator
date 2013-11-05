require 'active_support/core_ext/hash/indifferent_access'

module Aviator
class Test

  module Environment

    class << self

      attr_reader :config,
                  :path

      def init!
        @path = Pathname.new(__FILE__).join('..', '..', 'environment.yml').expand_path
        
        unless path.file?
          raise <<-EOF


=======================================================================
The test suite could not find an environment file at:

#{ path }

The test suite needs this so it will know which OpenStack environment
to connect to when creating new VCR cassettes. Please make one by
copying the contents of environment.yml.example.
=======================================================================


EOF
        end
        
        @config = YAML.load_file(path).with_indifferent_access
      end


      def method_missing(name, *args)
        if config.keys.include? name.to_s
          config[name.to_s]
        else
          super name, *args
        end
      end

    end

  end

  Environment.init!

end
end