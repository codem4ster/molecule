require 'power_strip'

module Molecule
  class PowerCable
    def self.send(interaction, params)
      interaction = interaction.gsub('/', '::').constantize
      outcome = interaction.run(params)
      result = {
        success: outcome.valid? || false,
        errors: outcome.errors.details,
        data: outcome.result
      }
      yield result
    end
  end
end

