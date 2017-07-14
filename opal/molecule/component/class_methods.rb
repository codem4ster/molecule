module Molecule
  module Component
    module ClassMethods
      def mount_to(element)
        new.mount_to(element)
      end

      def inject(clazz, opts = {})
        method_name = opts[:as] || clazz.to_s.downcase
        @injections ||= {}
        @injections[method_name] = clazz
      end

      def injections
        @injections || {}
      end

      def init
        define_method :before_render do |&block|
          return if @initied
          &block.call
          @inited = true
        end
      end
    end
  end
end