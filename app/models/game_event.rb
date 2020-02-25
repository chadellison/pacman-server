class GameEvent
  MOVE_EVENTS = ['up', 'left', 'right', 'down', 'leftStop', 'rightStop', 'upStop']
  FIRE_EVENTS = ['fire', 'fireStop']

  def self.handleEvent(game_data)
    player = Player.add_player(game_data) if game_data['gameEvent'] == 'start'
    player = Player.updated_player_for_move_event(game_data) if MOVE_EVENTS.include?(game_data['gameEvent'])
    player = Player.handle_fire(game_data) if FIRE_EVENTS.include?(game_data['gameEvent'])
    player = Player.remove_player(game_data['id']) if game_data['gameEvent'] == 'remove'
    GameEventBroadcastJob.perform_later(player)
  end
end
