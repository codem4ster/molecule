module Molecule
  module Component
    module VirtualDom
      def component(comp, opts = {}, &block)
        raise Error, "Component is nil in #{self.class} class" if comp.nil?
        @__virtual_nodes__ ||= []
        @__virtual_nodes__ << cache_component(comp) do
          comp = (comp.is_a?(Class) ? comp.new : comp)
            .with_root_component(@root_component)
            .inject
            .init
          comp
        end.with_props(opts[:props] || {}).render_virtual_dom(&block)
        self
      end

      def hook(mthd)
        VirtualDOM::Hook.method(method(mthd))
      end

      def unhook(mthd)
        VirtualDOM::UnHook.method(method(mthd))
      end
    end
  end
end