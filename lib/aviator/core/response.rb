module Aviator

  class Response
    

    def body
      @body ||= if response.body.length > 0
                  JSON.parse(response.body).with_indifferent_access
                else
                  {}
                end
                
      @body.dup
    end
    
    
    def method_missing(name, *args)
      case name
      when :headers, :status
        response.send(name)
      when :request
        request
      else
        super(name, *args)
      end
    end
    
    
    private
    
    attr_reader :response,
                :request
    
    def initialize(response, request)
      @response = response
      @request  = request
    end
    
  end
  
end