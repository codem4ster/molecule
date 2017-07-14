module Molecule
  module Browser
    module_function

    Window = JS.global
    Document = Window.JS[:document]
    AddEventListener = Window.JS[:addEventListener]

    if Native(Window.JS[:requestAnimationFrame])
      def animation_frame(&block)
        Window.JS.requestAnimationFrame(block)
      end
    else
      def animation_frame(&block)
        block.call
      end
    end

    def ready?(&block)
      AddEventListener.call('load', block)
    end

    def body
      Document.JS[:body]
    end

    def append_child(node, new_node)
      node = node.to_n unless native?(node)
      new_node = new_node.to_n unless native?(new_node)
      node.JS.appendChild(new_node)
    end

    def set_child(node, new_node)
      node = node.to_n unless native?(node)
      new_node = new_node.to_n unless native?(new_node)
      `#{node}.innerHTML = ''`
      node.JS.appendChild(new_node)
    end

    def query_element(css)
      Document.JS.querySelector(css)
    end

    Location = Document.JS[:location]
    History = Window.JS[:history]

    def path
      Location.JS[:pathname]
    end

    def query
      Location.JS[:search]
    end

    def decode_uri_component(value)
      JS.decodeURIComponent(value)
    end

    def push_state(path)
      History.JS.pushState({}, nil, path)
    end

    def on_pop_state(&block)
      Window.JS[:onpopstate] = block
    end

    def hash_change(&block)
      AddEventListener.call(:hashchange, block)
    end
  end
end