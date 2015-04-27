module Aviator

  class StrUtil

    class <<self

      def camelize(str)
        word = str.slice(0,1).capitalize + str.slice(1..-1)
        word.gsub(/_([a-zA-Z\d])/) { "#{$1.capitalize}" }
      end

      def constantize(str)
        str.split("::").inject(Object) do |namespace, sym|
          namespace.const_get(self.camelize(sym.to_s), false)
        end
      end

      def underscore(str)
        str.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
      end

    end

  end

end
