class Player
  START_COORDINATES = {'x' => 60, 'y' => 60}

  def self.create_player(game_data)
    player = {
      id: game_data['id'],
      score: game_data['score'],
      gold: game_data['gold'],
      location: START_COORDINATES,
      velocity: game_data['velocity'],
      angle: 0,
      trajectory: 0,
      accelerate: false,
      lastAccelerationTime: 0,
      rotate: 'none',
      weaponIndex: game_data['weaponIndex'],
      damage: game_data['damage'],
      fire: false,
      explode: false,
      hitpoints: game_data['hitpoints'],
      maxHitpoints: game_data['maxHitpoints'],
      armor: game_data['armor'],
      gameEvent: game_data['gameEvent'],
      shipIndex: game_data['shipIndex'],
      items: game_data['items'],
      updatedAt: (Time.now.to_f * 1000).round
    }
  end

  def self.get_players
    json_players = REDIS.get('players')
    if json_players.present?
      JSON.parse(json_players)
    else
      {}
    end
  end

  def self.add_player(game_data)
    player = create_player(game_data)
    players = get_players
    players[player[:id]] = player
    REDIS.set('players', players.to_json)
    player
  end

  def self.remove_player(userId)
    players = Player.get_players
    players.delete(userId.to_s)
    REDIS.set('players', players.to_json)
    {
      id: userId,
      gameEvent: 'remove',
      explodeAnimation: {x: 0, y: 0},
      explode: true,
      updatedAt: (Time.now.to_f * 1000).round
    }
  end

  def self.update_player(player_data)
    players = Player.get_players
    current_time = (Time.now.to_f * 1000).round
    player_data['lastAccelerationTime'] = current_time if player_data['gameEvent'] == 'upStop'
    player_data['updatedAt'] = current_time
    players[player_data['id']] = player_data
    REDIS.set('players', players.to_json)
    player_data
  end
end
