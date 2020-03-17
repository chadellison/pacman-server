class GameEvent
  MOVE_EVENTS = ['up', 'left', 'right', 'leftStop', 'rightStop', 'upStop']
  FIRE_EVENTS = ['fire', 'fireStop']

  def self.handleEvent(game_data)
    if MOVE_EVENTS.include?(game_data['gameEvent'])
      player = Player.updated_player_for_move_event(game_data)
    elsif FIRE_EVENTS.include?(game_data['gameEvent'])
      player = Player.handle_fire(game_data)
    elsif game_data['gameEvent'] == 'shop'
      player = Player.handle_shop(game_data)
    elsif game_data['gameEvent'] == 'start'
      player = Player.add_player(game_data)
    elsif game_data['gameEvent'] == 'remove'
      player = Player.remove_player(game_data['id'])
    end
    GameEventBroadcastJob.perform_later(player)
  end
end
