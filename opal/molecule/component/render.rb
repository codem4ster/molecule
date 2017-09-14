module Molecule
  module Component
    module Render
      def render
        raise Error, "Implement #render in #{self.class} component"
      end

      def render_if_root(rerendering = false)
        return unless @virtual_dom && @root_node
        new_virtual_dom = render_virtual_dom(rerendering)
        diff = VirtualDOM.diff(@virtual_dom, new_virtual_dom)
        VirtualDOM.patch(@root_node, diff)
        @virtual_dom = new_virtual_dom
      end

      def before_render; end
      def after_render; end
      def shared_init; end
      def shared_before; end
      def shared_after; end
      def client_init; end
      def shared_finish; end
      def client_finish; end

      def render_virtual_dom(rerendering = false, &block)
        @rerendering = rerendering
        before_render
        shared_before unless rerendering
        unless @__inited__
          client_init
          shared_init
        end
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
        shared_after unless rerendering
        unless @__finished__
          shared_finish
          client_finish
        end
        @__finished__ = true
        @rerendering = false
        result
      end
    end
  end
end