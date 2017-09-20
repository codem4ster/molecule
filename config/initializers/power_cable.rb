# Handle :message events in the "chat" channel.
# @param message [PowerStrip::Message] the message we received
# @param connection [Faye::WebSocket] the client connection this is from
PowerStrip.on :message, channel: 'power-cable' do |message, _connection|
  params = message.data['params']
  session_id = params.delete('_sid')
  if session_id
    session = Molecule::Session.new(session_id)
    params[:session] = session
  end
  interaction = message.data['interaction'].to_s.gsub('/', '::').constantize
  outcome = interaction.run(params)
  errors = {}
  unless outcome.valid?
    errors = outcome.errors.each_with_index.map do |field, i|
      [field[0], outcome.errors.full_messages[i]]
    end.to_h
  end
  PowerStrip[session_id].send :message, success: outcome.valid?,
                              errors: errors,
                              data: outcome.result,
                              '_uid' => message.data['_uid']
end