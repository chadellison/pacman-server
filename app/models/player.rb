class Player
  def self.create_player(game_data)
    player = {
      id: game_data['id'],
      score: game_data['score'],
      gold: game_data['gold'],
      location: game_data['location'],
      velocity: game_data['velocity'],
      angle: game_data['angle'],
      trajectory: game_data['trajectory'],
      accelerate: false,
      lastAccelerationTime: 0,
      rotate: 'none',
      weaponIndex: game_data['weaponIndex'],
      damage: game_data['damage'],
      explode: false,
      hitpoints: game_data['hitpoints'],
      maxHitpoints: game_data['maxHitpoints'],
      armor: game_data['armor'],
      gameEvent: game_data['gameEvent'],
      shipIndex: game_data['shipIndex'],
      items: game_data['items'],
      effects: game_data['effects'],
      explodeAnimation: {},
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
      player['trajectory'] = player_data['trajectory']
    when 'upStop'
      player['accelerate'] = false
      player['trajectory'] = player_data['trajectory']
      player['lastAccelerationTime'] = (Time.now.to_f * 1000).round
    when 'left'
      player['rotate'] = 'left'
    when 'leftStop'
      player['rotate'] = 'none'
    when 'right'
      player['rotate'] = 'right'
    when 'rightStop'
      player['rotate'] = 'none'
    when 'shop'
      player['armor'] = player_data['armor']
      player['damage'] = player_data['damage']
      player['weaponIndex'] = player_data['weaponIndex']
      player['velocity'] = player_data['velocity']
      player['shipIndex'] = player_data['shipIndex']
      player['maxHitpoints'] = player_data['maxHitpoints']
    when 'buff'
      player['buffIndex'] = player_data['buffIndex']
    end

    player['gameEvent'] = player_data['gameEvent']
    player['location'] = player_data['location']
    player['angle'] = player_data['angle']
    player['hitpoints'] = player_data['hitpoints']
    player['gold'] = player_data['gold']
    player['score'] = player_data['score']
    player['items'] = player_data['items']
    player['effects'] = player_data['effects']
    player['updatedAt'] = (Time.now.to_f * 1000).round

    players[player['id']] = player
    REDIS.set('players', players.to_json)
    player
  end

  def self.deploy_supply_ship
    {
      id: 'ai',
      location: {x: 1800, y: 1125},
      angle: 1,
      items: {},
      effects: {},
      score: 0,
      golde: 0,
      armor: rand(6),
      trajectory: rand(360),
      rotate: 'left',
      hitpoints: 500,
      maxHitpoints: 500,
      gameEvent: 'supplyShip',
      explodeAnimation: {},
      updatedAt: (Time.now.to_f * 1000).round
    }
  end
end
