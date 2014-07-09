module Aviator

  module Compatibility
    RUBY_1_8_MODE = (not (RUBY_VERSION =~ /1\.8\.\d*/).nil?)
  end

end

if Aviator::Compatibility::RUBY_1_8_MODE

  class Module

    alias_method :old_const_defined?, :const_defined?

    def const_defined?(sym, ignore=nil)
      old_const_defined?(sym)
    end


    alias_method :old_const_get, :const_get

    def const_get(sym, ignore=nil)
      old_const_get(sym)
    end

    alias_method :old_instance_methods, :instance_methods

    def instance_methods(include_super=true)
      old_instance_methods(include_super).map(&:to_sym)
    end

  end

end
