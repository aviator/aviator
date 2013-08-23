module Aviator
  
  class Request
    
    def initialize(params={})
      validate_params(params)
    end
    
    
    def allow_anonymous?
      false
    end
    
    
    def http_method
      :get
    end
    
    private
    
    def validate_params(params)
      validators = methods.select{ |name| name =~ /^param_validator_/ }
      validators.each do |name|
        send(name, params)
      end
    end
    
    
    class << self
      
      private
      
      def allow_anonymous
        define_method :allow_anonymous?, lambda { true }
      end
      
      
      def http_method(http_method_name)
        define_method :http_method, lambda { http_method_name }
      end
    
      
      def requires_param(param_name)
        last_num = instance_methods.map{|n| n.to_s.gsub(/^param_validator_/, '').to_i }.max
        
        define_method "param_validator_#{ last_num + 1 }".to_sym, lambda { |params| 
          raise ArgumentError.new("Missing parameter #{ param_name }.") unless params.keys.include? param_name
        }
      end
      
    end
    
  end
  
end