class GameDataChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'game_data'
  end

  def unsubscribed
    player_data = Player.remove_player(params['userId'])
    GameEventBroadcastJob.perform_later(player_data)
  end

  def create(opts)
    game_data = opts.fetch('gameData')
    GameEvent.handleEvent(game_data)
  end
end
