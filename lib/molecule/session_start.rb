require 'uuid'

module Molecule
  # Starts the session and writes an empty hash to redis cache
  class SessionStart < ActiveInteraction::Base

    string :guid, default: nil

    def execute
      self.guid = UUID.new.generate unless guid
      session = Molecule::Session.instance(guid)
      session.start
      guid
    end
  end
end
