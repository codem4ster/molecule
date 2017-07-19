require 'ostruct'

module Molecule
  # This renders the Component on server side
  module Component
    include AttributeBuilder
    include TagBuilder

    Molecule::HtmlTags.each do |tag_name|
      define_method tag_name do |attributes = nil, &content|
        tag(tag_name, attributes, &content)
      end
    end

    def before_render; end

    def after_render; end

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
      self.html_text += comp.parse
    end

    def parse
      before_render
      @depth = 0
      @tag_names = {}
      @attributes_s = {}
      result = render.to_s
      after_render
      result
    end

    def self.included(base)
      base.extend Molecule::Component::ClassMethods
    end

    # Classmethods of component module
    module ClassMethods
      def init(&block)
        define_method :before_render do
          self.instance_eval &block
        end
      end

      def interaction(name, interaction)
        define_method "#{name}!" do |params|
          Molecule::PowerCable.send(interaction, params) do |response|
            instance_variable_set("@#{name}".to_sym, response[:data])
          end
        end
        define_method name do
          instance_variable_get "@#{name}".to_sym
        end
      end
    end

    private

    def add_attributes(attributes)
      attributes.each do |key, value|
        key = key.to_sym
        add_attribute key, value
      end
    end

    def add_attribute(key, value)
      attributes[key] ||= ''
      attributes[key] += " #{value}"
      attributes[key] = attributes[key].gsub(/^ /, '')
    end

  end
end