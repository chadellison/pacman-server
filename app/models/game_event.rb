class GameEvent
  def self.handleEvent(game_data)
    handleStartEvent(game_data) if game_data['gameEvent'] == 'start'
    handleMoveEvent(game_data) if ['up', 'left', 'right', 'down'].include?(game_data['gameEvent'])
  end

  def self.handleStartEvent(game_data)
    player = Player.create_player(game_data)
    players = Player.get_players << player
    time_stamp = Time.now
    updated_players = players.map do |player|
      player['location'] = Player.calculateLocation(player)
      player['updated_at'] = time_stamp
      player
    end
    REDIS.set('players', updated_players.to_json)
    GameEventBroadcastJob.perform_later(updated_players)
  end

  def self.handleMoveEvent(game_data)
    time_stamp = Time.now
    updatedPlayers = Player.get_players.map do |player|
      if player['id'] == game_data['id']
        player['direction'] = game_data['gameEvent']
      end
      player['location'] = game_data['playerLocations'][player['id'].to_s]
      player['updated_at'] = time_stamp
      player
    end
    REDIS.set('players', updatedPlayers.to_json)
    GameEventBroadcastJob.perform_later(updatedPlayers)
  end
end
