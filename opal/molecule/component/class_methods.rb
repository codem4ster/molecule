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

      def component(method_name, clazz)
        define_method method_name do |props , &block|
          component clazz, props: props, &block
        end
      end

      def interaction(name, interaction)
        define_method "#{name}!" do |params|
          params[:_sid] = Molecule::Session.key
          Molecule::PowerCable.send(interaction, params) do |response|
            instance_variable_set("@#{name}".to_sym, response)
            render!
          end
        end
        define_method "#{name}?" do
          variable = instance_variable_get "@#{name}".to_sym
          { success: variable[:success], errors: variable[:errors] }
        end
        define_method name do
          variable = instance_variable_get "@#{name}".to_sym
          variable ? variable[:data] : {}
        end
        define_method "#{name}=" do |val|
          variable = instance_variable_get "@#{name}".to_sym
          if variable
            variable[:data] = val
          else
            instance_variable_set "@#{name}", { data: val }
          end
        end
      end
    end
  end
end