class String

  unless instance_methods.include? 'camelize'
    define_method :camelize do
      word = self.slice(0,1).capitalize + self.slice(1..-1)
      word.gsub(/_([a-zA-Z\d])/) { "#{$1.capitalize}" }
    end
  end

  unless instance_methods.include? 'constantize'
    define_method :constantize do
      self.split("::").inject(Object) do |namespace, sym|
        namespace.const_get(sym.to_s.camelize, false)
      end
    end
  end

  unless instance_methods.include? 'underscore'
    define_method :underscore do
      self.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
    end
  end

end
