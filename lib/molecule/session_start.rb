require 'uuid'

module Molecule
  # Starts the session and writes an empty hash to redis cache
  class SessionStart < ActiveInteraction::Base

    def execute
      guid = UUID.new.generate
      session = Molecule::Session.new(guid)
      session.start
      guid
    end
  end
end
