class GameDataChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'game_data'
  end

  def unsubscribed
    Player.unsubscribe_player(params['userId'])
  end

  def create(opts)
    game_data = opts.fetch('gameData')
    GameEvent.handle_event(game_data)
  end
end
