module Molecule
  module Config
    SOURCE_MAP_PREFIX = '/__OPAL_MAPS__'.freeze
    ASSETS_PREFIX = '/__ASSETS__'.freeze
    STATIC_DIR = '/static'.freeze
    BUILD_DIR = 'dist'.freeze
    APP_DIR = 'app'.freeze
    APP_DEV_DIR = 'app_dev'.freeze
    APP_DIST_DIR = 'app_dist'.freeze

    class << self
      attr_writer :redis_session_store

      def redis_session_store
        @redis_session_store ||= Redis.new(host: '10.0.1.1', port: 6379, db: 15)
      end
    end
  end
end