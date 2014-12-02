# Dummy Provider
#
# We use this dummy provider to decouple Aviator
# core tests from any specific Aviator application.
module Aviator::Dummy
module Provider

  class << self

    def find_request(service, name, session_data, options)
      fqrn = "Aviator::Dummy::#{service.to_s.camelize}::Requests::V1::Public::#{name.to_s.camelize}"
      fqrn.constantize
    rescue NameError => e
      raise NameError.new("#{fqrn} not found: #{e.message}")
    end


    def request_file_paths(service)
      path_glob = ['..', service.to_s, 'requests', '**', '*.rb']
      Dir.glob(Pathname.new(__FILE__).join(*path_glob).expand_path)
    end


    def root_dir
      Pathname.new(__FILE__).join('..').expand_path
    end

  end

end
end
