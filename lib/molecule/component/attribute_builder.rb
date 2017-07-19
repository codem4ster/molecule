module Molecule
  module Component
    # Builds attributes for the component
    module AttributeBuilder
      def attributes
        @attributes_s[@depth] ||= {}
      end

      def attributes=(val)
        @attributes_s[@depth] = val
      end

      private

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

      def reject_callbacks
        attributes.reject! do |key, _handler|
          key[0, 2] == 'on' || key == 'hook' || key == 'unhook'
        end
      end

      def build_attributes
        return unless attributes.is_a? Hash

        check_class_name
        build_style
        reject_callbacks

        attributes.map do |key, value|
          next " #{key}" if value.eql? true
          value = '"' + value + '"'
          ' ' + [key, value].join('=')
        end.join
      end
    end
  end
end