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
      lastEvent: game_data['gameEvent'],
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

  def self.updated_player_for_move_event(game_data)
    players = Player.get_players
    player = players[game_data['id'].to_s]
    player = handleAcceleration(player, game_data['gameEvent']) if ['up', 'upStop'].include?(game_data['gameEvent'])
    player = handleRotation(player, game_data['gameEvent']) if ['left', 'right', 'leftStop', 'rightStop'].include?(game_data['gameEvent'])
    player = update_attributes(player, game_data)

    players[player['id']] = player
    REDIS.set('players', players.to_json)
    player
  end

  def self.handleAcceleration(player, game_event)
    if game_event == 'up'
      player['accelerate'] = true
    else
      player['accelerate'] = false if game_event == 'upStop'
      player['lastAccelerationTime'] = (Time.now.to_f * 1000).round if game_event == 'upStop'
    end
    player['trajectory'] = player['angle']

    player
  end

  def self.handleRotation(player, game_event)
    if (['leftStop', 'rightStop'].include?(game_event))
      player['rotate'] = 'none'
    else
      player['rotate'] = game_event
    end
    player
  end

  def self.handle_fire(game_data)
    players = Player.get_players
    player = players[game_data['id'].to_s]
    player['fire'] = game_data['gameEvent'] == 'fire'
    player = update_attributes(player, game_data)
    players[player['id']] = player
    REDIS.set('players', players.to_json)
    player
  end

  def self.handle_shop(game_data)
    players = Player.get_players
    player = players[game_data['id'].to_s]
    player['lastEvent'] = 'shop'
    player['armor'] = game_data['armor']
    player['shipIndex'] = game_data['shipIndex']
    player['weaponIndex'] = game_data['weaponIndex']
    player['maxHitpoints'] = game_data['maxHitpoints']
    player['damage'] = game_data['damage']
    player['velocity'] = game_data['velocity']
    player = update_attributes(player, game_data)

    players[player['id']] = player
    REDIS.set('players', players.to_json)
    player
  end

  def self.remove_player(userId)
    players = Player.get_players
    players.delete(userId.to_s)
    REDIS.set('players', players.to_json)
    {
      id: userId,
      lastEvent: 'remove',
      explodeAnimation: {x: 0, y: 0},
      explode: true,
      updatedAt: (Time.now.to_f * 1000).round
    }
  end

  def self.update_attributes(player, game_data)
    player['lastEvent'] = game_data['gameEvent']
    player['location'] = game_data['location']
    player['angle'] = game_data['angle']
    player['hitpoints'] = game_data['hitpoints']
    player['gold'] = game_data['gold']
    player['score'] = game_data['score']
    player['items'] = game_data['items']
    player['updatedAt'] = (Time.now.to_f * 1000).round
    player
  end
end
