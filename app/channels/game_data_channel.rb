class GameDataChannel < ApplicationCable::Channel
  def subscribed
    # conversation = Conversation.find(params[:conversation])
    stream_from 'game_data'
  end

  def unsubscribed
    Player.remove_player(params['userId'])
    GameEventBroadcastJob.perform_later(Player.get_players)
  end

  def create(opts)
    game_data = opts.fetch('gameData')
    GameEvent.handleEvent(game_data)
  end
end
