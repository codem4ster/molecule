require 'ostruct'

module Molecule
  module Component

    Molecule::HtmlTags.each do |tag_name|
      define_method tag_name do |attributes = nil, &content|
        tag(tag_name, attributes, &content)
      end
    end

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

    def attributes
      @attributes_s[@depth] ||= {}
    end

    def attributes=(val)
      @attributes_s[@depth] = val
    end

    def text(val)
      self.html_text += val
    end

    def run(interaction, params)
      interaction.run(params)
    end

    def eval_content(&content)
      @depth += 1
      result = instance_eval(&content)
      @depth -= 1
      return if html_text == result.to_s
      result = result.join if result.is_a? Array
      self.html_text += result.to_s
    end

    def build_style
      return unless attributes[:style].is_a? Hash
      attributes[:style] = attributes[:style].map do |attr, value|
        attr = attr.to_s.tr('_', '-')
        "#{attr}:#{value}"
      end.join(';')
    end

    def check_class_name
      map = %i[class_name className]
      found = map.find { |cls_name| attributes.key?(cls_name) }
      return attributes unless found
      attributes[:class] ||= attributes.delete(found)
    end

    def build_attributes
      return unless attributes.is_a? Hash

      check_class_name
      build_style

      attributes.reject! do |key, handler|
        key[0, 2] == 'on'
      end

      attributes.map do |key, value|
        next " #{key}" if value.eql? true
        value = '"' + value + '"'
        ' ' + [key, value].join('=')
      end.join
    end

    def tag(tag_name, attributes = nil, &content)
      self.attributes = (attributes || {})
      self.tag_name = tag_name
      return self if !block_given? && attributes.nil?
      render_to_html(&content)
      self
    end

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

    def to_s
      html_text
    end

    def props
      @props ||= {}
    end

    def props=(val)
      @props = val
    end

    def component(name, options = {})
      comp = name.new
      comp.props = options[:props]
      comp.parse
    end

    def parse
      @depth = 0
      @tag_names = {}
      @attributes_s = {}
      render.to_s
    end

    def method_missing(method, attributes = nil, &content)
      if attributes
        attributes.each do |key, value|
          key = key.to_sym
          self.attributes[key] ||= ''
          self.attributes[key] += " #{value}"
          self.attributes[key] = self.attributes[key].gsub(/^ /, '')
        end
      end
      if method.to_s.end_with?('!')
        self.attributes['id'] = method.to_s[0..-2]
      else
        self.attributes[:class] ||= ''
        self.attributes[:class] += " #{method}"
        self.attributes[:class] = self.attributes[:class].gsub(/^ /, '')
      end
      return self if !block_given? && attributes.nil?
      render_to_html(&content)
      self
    end

    def self.included(base)
      base.extend Molecule::Component::ClassMethods
    end

    module ClassMethods
      def init
        define_method :before_render do
          yield
        end
      end
    end

  end
end