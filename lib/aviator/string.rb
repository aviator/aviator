class String

  def camelize
    word = self.slice(0,1).capitalize + self.slice(1..-1)
    word.gsub(/_([a-zA-Z\d])/) { "#{$1.capitalize}" }
  end

  def constantize
    self.split("::").inject(Object) do |namespace, sym|
      namespace.const_get(sym.to_s.camelize, false)
    end
  end

  def underscore
    self.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
  end

end
