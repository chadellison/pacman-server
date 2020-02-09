class GameDataChannel < ApplicationCable::Channel
  def subscribed
    # conversation = Conversation.find(params[:conversation])
    stream_from 'game_data'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def create(opts)
    game_data = opts.fetch('gameData')
    GameEvent.handleEvent(game_data)
  end
end
