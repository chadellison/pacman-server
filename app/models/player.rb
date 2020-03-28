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
    player = players[player_data['id'].to_s]
    case player_data['gameEvent']
    when 'up'
      player['accelerate'] = true
      player['trajectory'] = player_data['angle']
    when 'upStop'
      player['accelerate'] = false
      player['trajectory'] = player_data['angle']
      player['lastAccelerationTime'] = (Time.now.to_f * 1000).round
    when 'left'
      player['rotate'] = 'left'
    when 'leftStop'
      player['rotate'] = 'none'
    when 'right'
      player['rotate'] = 'right'
    when 'rightStop'
      player['rotate'] = 'none'
    when 'fire'
      player['fire'] = true
    when 'fireStop'
      player['fire'] = false
    when 'shop'
      player['armor'] = player_data['armor']
      player['damage'] = player_data['damage']
      player['weaponIndex'] = player_data['weaponIndex']
      player['velocity'] = player_data['velocity']
      player['shipIndex'] = player_data['shipIndex']
      player['maxHitpoints'] = player_data['maxHitpoints']
    end

    player['gameEvent'] = player_data['gameEvent']
    player['location'] = player_data['location']
    player['angle'] = player_data['angle']
    player['hitpoints'] = player_data['hitpoints']
    player['lives'] = player_data['lives']
    player['gold'] = player_data['gold']
    player['score'] = player_data['score']
    player['items'] = player_data['items']
    player['sentTime'] = player_data['sentTime']
    current_time = (Time.now.to_f * 1000).round
    player['updatedAt'] = current_time
    player['timeDifference'] = current_time - Time.at(player_data['sentTime'].to_f).utc.to_f

    players[player['id']] = player
    REDIS.set('players', players.to_json)
    player
  end
end
