class GameDataChannel < ApplicationCable::Channel
  def subscribed
    # conversation = Conversation.find(params[:conversation])
    stream_from 'game_data'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def create(opts)
    game_event_data = opts.fetch('gameEventData')
    GameData.handleEvent(game_event_data)
  end
end
