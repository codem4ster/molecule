# Handle :message events in the "chat" channel.
# @param message [PowerStrip::Message] the message we received
# @param connection [Faye::WebSocket] the client connection this is from
PowerStrip.on :message, channel: 'power_cable' do |message, _connection|
  outcome = message.data['interaction'].to_s.gsub('/', '::').constantize.run(message.data['params'])
  PowerStrip[message.channel].send :message, success: outcome.valid?,
                                             errors: outcome.errors.details,
                                             data: outcome.result,
                                             '_uid' => message.data['_uid']
end