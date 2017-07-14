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
      
      def interaction(name, interaction)
        define_method "#{name}!" do |params|
          Molecule::PowerCable.send('Users/CreateUser', params) do |response|
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
          variable ? variable[:data] : nil
        end
      end

      def init(&block)
        define_method :before_render do
          unless self.instance_eval { @initied }
            self.instance_eval(&block)
          end
          self.instance_eval { @initied = true }
        end
      end
    end
  end
end