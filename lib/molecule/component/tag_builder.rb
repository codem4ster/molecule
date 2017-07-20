module Molecule
  module Component
    # Build tag for component
    module TagBuilder
      def html_text
        @html_text ||= ''
      end

      def html_text=(val)
        @html_text = val
      end

      def tag_name=(val)
        @tag_names[@depth] = val
      end

      def tag_name
        @tag_names[@depth]
      end

      def text(val)
        self.html_text += val
      end

      def tag(tag_name, attributes = nil, &content)
        self.func_count += 1
        self.tag_name = tag_name
        if attributes.kind_of? String
          self.attributes = {}
          render_to_html { attributes }
        else
          self.attributes = (attributes || {})
          return self if !block_given? && attributes.nil?
          render_to_html(&content)
        end
        self
      end

      def method_missing(method, attributes = nil, &content)
        if attributes.kind_of? String
          kl = attributes.clone
          content = Proc.new { kl }
          attributes = {}
        elsif !attributes.nil?
          add_attributes(attributes)
        end
        if method.to_s.end_with?('!')
          self.attributes['id'] = method.to_s[0..-2]
        else
          add_attribute :class, method
        end
        return self if !block_given? && attributes.nil?
        render_to_html(&content)
        self
      end

      private

      def render_to_html(&content)
        start_tag = "<#{tag_name}#{build_attributes}"
        self.html_text += start_tag
        if block_given?
          self.html_text += '>'
          eval_content(&content)
          self.html_text += "</#{tag_name}>"
        else
          self.html_text += ' />'
        end
      end
    end
  end
end