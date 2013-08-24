require 'active_support/core_ext/hash/indifferent_access'

module Aviator
module Test
  
  module Environment
    
    class << self
      
      attr_reader :config
      
      def init!
        config_path = Pathname.new(__FILE__).join('..', '..', 'environment.yml').expand_path

        raise "Environment file #{ config_path } does not exist. Please make one." unless config_path.file?
      
        @config = YAML.load_file(config_path).with_indifferent_access
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