module Molecule
  class PowerCable

    BASE_URL = `window.location.origin`
    client = PowerStrip::Client.new(BASE_URL.gsub(/http|https/, 'ws') + '/power_cable')

    client.on(:connect) { pp_log 'power cable connected' }
    client.on(:disconnect) { pp_log 'power cable disconnected' }

    CHANNEL = client.subscribe(:power_cable)

    @messages = {}
    CHANNEL.on :message do |response|
      data = response.data[:data]
      g_uid = response.data['_uid']
      message = @messages.delete(g_uid)
      message.call(data)
    end

    @chars = %w[a A b B c C ç Ç d D e E f F g G ğ Ğ h H ı I i İ j J k K l L m M n N o O ö Ö p P q Q r R s S ş Ş t T]
    @chars += %w[u U ü Ü x X w W v V y Y z Z 0 1 2 3 4 5 6 7 8 9 ! " ^ $ % & ' ( ) = + * ~ , . ` @ { } - _ ? ; < >]

    def self.uid
      @chars.sample(8).join
    end

    def self.send(interaction, params, &block)
      g_uid = uid
      promise = CHANNEL.message interaction: interaction, params: params, '_uid' => g_uid
      @messages[g_uid] = block
    end
  end
end