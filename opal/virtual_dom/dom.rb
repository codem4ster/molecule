module VirtualDOM
  module DOM
    HTML_TAGS = %w(a abbr address area article aside audio b base bdi bdo big blockquote body br
                  button canvas caption cite code col colgroup data datalist dd del details dfn
                  dialog div dl dt em embed fieldset figcaption figure footer form h1 h2 h3 h4 h5
                  h6 head header hr html i iframe img input ins kbd keygen label legend li link
                  main map mark menu menuitem meta meter nav noscript object ol optgroup option
                  output p param picture pre progress q rp rt ruby s samp script section select
                  small source span strong style sub summary sup table tbody td textarea tfoot th
                  thead time title tr track u ul var video wbr)

    HTML_TAGS.each do |tag|
      define_method tag do |params = {}, &block|
        process_tag(tag, params, block)
      end
    end

    def process_tag(tag, params, block)
      @__virtual_nodes__ ||= []
      if block
        current = @__virtual_nodes__
        @__virtual_nodes__ = []
        result = block.call || ''
        vnode = VirtualNode.new(tag, process_params(params), @__virtual_nodes__.count.zero? ? result : @__virtual_nodes__)
        @__virtual_nodes__ = current
      elsif params.is_a?(String)
        vnode = VirtualNode.new(tag, {}, [params])
      else
        vnode = VirtualNode.new(tag, process_params(params), [])
      end
      @__last_virtual_node__ = vnode
      @__virtual_nodes__ << @__last_virtual_node__.to_n
      self
    end

    def method_missing(clazz, params = {}, &block)
      return unless @__last_virtual_node__
      return unless @__virtual_nodes__
      @__virtual_nodes__.pop
      block = -> { params } if params.is_a? String
      method_params = method_params(clazz, params)
      process_tag(@__last_virtual_node__.name, method_params, block)
    end

    def method_params(clazz, params)
      class_params = merged_class_params(params, clazz)
      class_params.merge! params if params.is_a? Hash
      @__last_virtual_node__.params.merge(class_params)
      class_params
    end

    def merged_class_params(params, clazz)
      classes = @__last_virtual_node__.params.delete(:className)
      id = @__last_virtual_node__.params.delete(:id)
      param_hash = { id: id, class: join_str(classes, params[:class]) }
      if clazz.end_with?('!')
        param_hash[:id] = clazz[0..-2]
      else
        reverted_clazz = clazz.tr('_', '-').gsub('--', '_')
        param_hash[:class] = join_str param_hash[:class], reverted_clazz
      end
      param_hash.reject { |_, v| v.nil? }
    end

    def join_str(*params)
      params.join(' ').strip
    end

    def process_params(params)
      return {} unless params.is_a?(Hash)
      param_map = { 'for' => 'htmlFor', 'class' => 'className',
                    'data' => 'dataset', 'default' => 'defaultValue' }
      params.dup.each do |k, v|
        if param_map.key?(k)
          params[param_map[k]] = params.delete(k)
        elsif k =~ /^on/
          params[k] = event_callback(v)
        end
      end
      params
    end

    def event_callback(v)
      proc do |e|
        v.call(Support.wrap_event(e))
      end
    end

    def text(string)
      @__virtual_nodes__ << string.to_s
    end

    def to_vnode
      if @__virtual_nodes__.one?
        @__virtual_nodes__.first
      else
        VirtualNode.new('div', {id: '__virtual_root__'}, @__virtual_nodes__).to_n
      end
    end

    def class_names(hash)
      class_names = []
      hash.each do |key, value|
        class_names << key if value
      end
      class_names.join(' ')
    end
  end
end
