module Aviator

  # Because we define requests via blocks, we want to make sure that when each
  # request is initialized it doesn't get polluted by instance variables and methods
  # of the containing class. This builder class makes that happen by being a
  # scope gate for the file.
  class RequestBuilder
    
    def define_request(request_name, &block)
      klass = Class.new(Aviator::Request, &block)
      return request_name, klass
    end
    

    def self.build(path_to_request_file)
      clean_room = self.new
      clean_room.instance_eval(File.read(path_to_request_file))
    end

  end

end