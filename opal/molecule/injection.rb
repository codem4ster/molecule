module Molecule
  module Injection
    def init; self end

    def with_root_component(component)
      @root_component = component
      self
    end

    def inject
      @root_component.injections.each do |name, instance|
        define_singleton_method(name) do
          instance
        end
      end
      self
    end

    attr_reader :injections
    def init_injections
      @injections ||= {}
      self.class.injections.each do |name, clazz|
        if clazz.included_modules.include?(Molecule::Injection)
          @injections[name] = clazz
            .new
            .with_root_component(@root_component)
        else
          raise Error, "Invalid #{clazz} class, should mixin Inesita::Injection"
        end
      end
      @injections.each do |key, instance|
        instance.inject
        instance.init
      end
    end

    def render!(rerendering=true)
      Browser.animation_frame do
        @root_component.render_if_root(rerendering)
      end
    end
  end
end