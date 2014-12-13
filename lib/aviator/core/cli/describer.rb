module Aviator

  class Describer

    class InvalidProviderNameError < StandardError
      def initialize(name)
        super "Provider '#{ name }' does not exist."
      end
    end


    def self.describe_aviator
      str = "Available providers:\n"

      provider_names.each do |provider_name|
        str << "  #{ provider_name }\n"
      end

      str
    end


    def self.describe_provider(provider_name)
      str = "Available services for #{ provider_name }:\n"

      service_names(provider_name).each do |service_name|
        str << "  #{ service_name }\n"
      end

      str
    end


    def self.describe_request(provider_name, service_name, api_version, endpoint_type, request_name)
      service = Aviator::Service.new :provider => provider_name, :service => service_name
      request_class = "Aviator::#{ provider_name.camelize }::#{ service_name.camelize }::Requests::"\
                      "#{ api_version.camelize }::#{ endpoint_type.camelize }::#{ request_name.camelize }".constantize

      display = "Request: #{ request_name }\n"


      # Build the parameters
      params = request_class.optional_params.map{|p| [p, false]} +
               request_class.required_params.map{|p| [p, true]}

      aliases = request_class.param_aliases

      if params.length > 0
        display << "\n"

        headings = ['NAME', 'REQUIRED?']

        headings << 'ALIAS' if aliases.length > 0

        rows = []
        params.sort{|a,b| a[0].to_s <=> b[0].to_s }.each do |param|
          row = [ param[0], param[1] ? 'Y' : 'N' ]

          if aliases.length > 0
            row << (aliases.find{|a,p| p == param[0] } || [''])[0]
          end

          rows << row
        end

        widths = [
          rows.map{|row| row[0].to_s.length }.max,
          rows.map{|row| row[1].to_s.length }.max
        ]

        widths << rows.map{|row| row[2].to_s.length }.max if aliases.length > 0

        table = Terminal::Table.new(:headings => headings, :rows => rows)

        table.align_column(1, :center)

        display << "Parameters:\n"
        display << " " + table.to_s.split("\n").join("\n ")
        display << "\n"
      end


      # Build the sample code
      display << "\nSample Code:\n"

      display << "  session.request(:#{ service_name }_service, :#{ request_name })"

      if params && params.length > 0
        display << " do |params|\n"
        params.each do |pair|
          display << "    params.#{ (aliases.find{|a,p| p == pair[0] } || pair)[0] } = value\n"
        end
        display << "  end"
      end

      display << "\n"


      # Build the links
      if request_class.links && request_class.links.length > 0
        display << "\nLinks:\n"

        request_class.links.each do |link|
          display << "  #{ link[:rel] }:\n"
          display << "    #{ link[:href] }\n"
        end
      end

      display
    end


    def self.describe_service(provider_name, service_name)
      requests = request_classes(provider_name, service_name)

      if requests.empty?
        str = "No requests found for #{ provider_name } #{ service_name }_service."
      else
        str = "Available requests for #{ provider_name } #{ service_name }_service:\n"

        requests.each do |klass|
          str << "  #{ klass.api_version } #{ klass.endpoint_type } #{ klass.name.split('::').last.underscore }\n"
        end

        str
      end
    end


    class <<self
      private

      def provider_names
        Pathname.new(__FILE__) \
          .join('..', '..', '..') \
          .children \
          .select{|c| c.directory? && c.basename.to_s != 'core' } \
          .map{|c| c.basename.to_s }
      end


      def request_classes(provider_name, service_name)
        service = Aviator::Service.new(:provider => provider_name, :service => service_name)
        service.request_classes
      end


      def service_names(name)
        provider = Pathname.new(__FILE__).join('..', '..', '..', name)

        raise InvalidProviderNameError.new(name) unless provider.exist?

        provider.children \
                .select{|c| c.directory? } \
                .map{|c| c.basename.to_s }
      end
    end

  end

end
