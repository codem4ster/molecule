require 'promise'

module Molecule
  # Controls the session for client side
  class Session
    attr_writer :key

    def key
      @key ||= Molecule::Cookie.get(:s_id)
    end

    def request_key
      Molecule::PowerCable.send('Molecule/SessionStart') do |response|
        self.key = response[:data]
        Molecule::Cookie.set(:s_id, response[:data], 30.minutes)
      end
    end

    def destroy
      Molecule::Cookie.set(:s_id, nil, 1.second)
    end

    class << self
      @instance = nil

      def create
        promise = Promise.new
        if @instance
          promise.resolve @instance
        else
          @instance = new
          if @instance.key
            promise.resolve @instance
          else
            @instance.request_key.then { promise.resolve(@instance) }
          end
        end
        promise
      end
    end
  end
end