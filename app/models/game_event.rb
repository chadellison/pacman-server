class GameEvent
  def self.handleEvent(game_data)
    handleStartEvent(game_data) if game_data['gameEvent'] == 'start'
    handleMoveEvent(game_data) if ['up', 'left', 'right', 'down'].include?(game_data['gameEvent'])
  end

  def self.handleStartEvent(game_data)
    player = Player.createPlayer(game_data)
    updatedPlayers = Player.getPlayers << player
    REDIS.set('players', updatedPlayers.to_json)
    GameEventBroadcastJob.perform_later(updatedPlayers)
  end

  def self.handleMoveEvent(game_data)
    updatedPlayers = Player.getPlayers.map do |player|
      if player['id'] == game_data['id']
        player['direction'] = game_data['gameEvent']
      end
      player['location'] = game_data['playerLocations'][player['id'].to_s]
      player['updated_at'] = Time.now
      player
    end
    REDIS.set('players', updatedPlayers.to_json)
    GameEventBroadcastJob.perform_later(updatedPlayers)
  end

  def self.calculateLocation(player)
    difference_in_milliseconds = (Time.now - Time.new(player['updated_at'])) * 1000 / 30.0
    distance = (5 * difference_in_milliseconds).round
    case player['direction']
    when 'up'
      y = distance <= 25 ? 25 : distance
      location = {x: player['location']['x'], y: y }
    when 'left'
      x = distance <= 25 ? 25 : distance
      location = {x: x, y: player['location']['y']}
    when 'right'
      x = distance >= 980 - 25 ? 980 - 25 : distance
      location = {x: x, y: player['location']['y']}
    when 'down'
      y = distance >= 665 - 25 ? 665 - 25 : distance
      location = {x: player['location']['x'], y: y}
    end
  end
end
