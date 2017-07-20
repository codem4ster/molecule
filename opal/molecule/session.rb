require 'promise'

module Molecule
  # Controls the session for client side
  class Session
    attr_writer :key

    def key
      @key ||= (Molecule::Cookie.get(:_sid) || generate_key)
    end

    def generate_key
      key = Molecule::Uid.generate(16)
      Molecule::Cookie.set(:_sid, key, 1.year)
      key
    end

    def destroy
      Molecule::Cookie.set(:_sid, nil, 1.second)
    end

    class << self
      attr_writer :instance

      def instance
        @instance ||= new
      end

      def key
        instance.key
      end
    end
  end
end