require 'promise'

module Molecule
  class PowerCable
    Document.ready? do
      unless `window.__server_rendered__`
        BASE_URL = `window.location.origin`
        path = '/molecule/power_cable'
        client = PowerStrip::Client.new(BASE_URL.gsub(/http|https/, 'ws') + path)

        client.on(:connect) { puts 'power cable connected' }
        client.on(:disconnect) { puts 'power cable disconnected' }

        GLOBAL_CHANNEL = client.subscribe('power-cable')
        CHANNEL = client.subscribe(Molecule::Session.key)

        @blocks = {}
        @promises = {}
        CHANNEL.on :message do |response|
          g_uid = response.data['_uid']
          @blocks.delete(g_uid).call(response.data)
          @promises.delete(g_uid).resolve(response.data)
        end
      end
    end

    def self.send(interaction, params = {}, &block)
      promise = Promise.new
      g_uid = Molecule::Uid.generate(8)
      GLOBAL_CHANNEL.message interaction: interaction,
                             params: params,
                             '_uid' => g_uid
      @blocks[g_uid] = block
      @promises[g_uid] = promise
      promise
    end
  end
end