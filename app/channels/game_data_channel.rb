class GameDataChannel < ApplicationCable::Channel
  def subscribed
    # conversation = Conversation.find(params[:conversation])
    stream_from 'game_data'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def create(opts)
    game_event = opts.fetch('gameEvent')
    # pull game out of redis
    # update game data
    # write to redis
    # and then broadcast
    GameEventBroadcastJob.perform_later(game_event)
  end
end
