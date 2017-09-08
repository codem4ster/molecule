module Molecule
  module Component
    module Render
      def render
        raise Error, "Implement #render in #{self.class} component"
      end

      def render_if_root
        return unless @virtual_dom && @root_node
        new_virtual_dom = render_virtual_dom
        diff = VirtualDOM.diff(@virtual_dom, new_virtual_dom)
        VirtualDOM.patch(@root_node, diff)
        @virtual_dom = new_virtual_dom
      end

      def before_render; end;
      def after_render; end;
      def shared_init; end;
      def shared_after; end;

      def render_virtual_dom(&block)
        before_render
        shared_init unless @__inited__
        @__inited__ = true
        @cache_component_counter = 0
        @__virtual_nodes__ = []
        if block_given?
          render(&block)
        else
          render
        end
        result = to_vnode
        after_render
        shared_after unless @__finished__
        @__finished__ = true
        result
      end
    end
  end
end