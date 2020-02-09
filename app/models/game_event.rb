class GameEvent
  def self.handleEvent(game_data)
    handleStartEvent(game_data) if game_data['gameEvent'] == 'start'
    handleMoveEvent(game_data) if ['up', 'left', 'right', 'down'].include?(game_data['gameEvent'])
  end

  def self.handleStartEvent(game_data)
    updated_players = Player.updated_players_for_start_event(game_data)
    GameEventBroadcastJob.perform_later(updated_players)
  end

  def self.handleMoveEvent(game_data)
    updatedPlayers = Player.updated_players_for_move_event(game_data)
    GameEventBroadcastJob.perform_later(updatedPlayers)
  end
end
