module Molecule
  class Session

    @store = Molecule::Config.redis_session_store
    attr_reader :key, :ttl

    def initialize(key, ttl = 30.minutes)
      @key = key
      @ttl = ttl
    end

    def set(var_key, value)
      data = @store.get key
      @store.set key, data.merge(var_key => value)
      @store.expire key, ttl
    end

    def get(var_key)
      @store.expire key, ttl
      data = @store.get key
      data[var_key] if data
    end

    class << self
      attr_reader :store

      def clear
        store.flushdb
      end
    end

  end
end