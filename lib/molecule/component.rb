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

    def shared_init; end
    def server_init; end
    def shared_before; end
    def shared_after; end
    def server_before; end
    def server_after; end
    def shared_finish; end

    def run(interaction, params)
      interaction.run(params)
    end

    def eval_content(&content)
      @depth += 1
      self.func_count = 0
      result = instance_eval(&content)
      result = nil if func_count > 0
      @depth -= 1
      return unless result.is_a? String
      return if html_text == result
      self.html_text += result.to_s
    end

    def to_s
      html_text
    end

    def func_count
      @func_count_s[@depth] ||= 0
    end

    def func_count=(val)
      @func_count_s[@depth] = val
    end

    def props
      @props ||= {}
    end

    def props=(val)
      @props = val
    end

    def component(name, options = {}, &block)
      comp = name.new
      comp.props = options[:props]
      parsed = comp.parse(&block)
      self.html_text += parsed
    end

    def parse(&block)
      shared_init
      server_init
      shared_before
      server_before
      @depth = 0
      @tag_names = {}
      @func_count_s = {}
      @attributes_s = {}
      result = render(&block).to_s
      server_after
      shared_after
      shared_finish
      result
    end

    def self.included(base)
      base.extend Molecule::Component::ClassMethods
    end

    # Classmethods of component module
    module ClassMethods

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

      def component(method_name, clazz)
        define_method method_name do |props, &block|
          component clazz, props: props, &block
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
      if value.is_a? Hash
        attributes[key] ||= {}
        attributes[key].merge! value
      else
        attributes[key] ||= ''
        attributes[key] += " #{value}"
        attributes[key] = attributes[key].strip
      end
    end

  end
end