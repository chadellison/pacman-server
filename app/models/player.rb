class Player
  START_COORDINATES = {'x' => 60, 'y' => 60}
  VELOCITY = 4
  ANIMATION_FRAME_RATE = 30.0

  def self.create_player(game_data)
    player = {
      id: game_data['id'],
      name: Faker::Name.name,
      score: 0,
      location: START_COORDINATES,
      velocity: VELOCITY,
      angle: 0,
      trajectory: 0,
      accelerate: false,
      lastAccelerationTime: 0,
      rotate: 'none',
      weapon: 1,
      fire: false,
      lastFired: 0,
      hitpoints: game_data['hitpoints'],
      maxHitpoints: game_data['maxHitpoints'],
      armor: game_data['armor'],
      lives: 3,
      lastEvent: game_data['gameEvent'],
      updatedAt: (Time.now.to_f * 1000).round
    }
  end

  def self.get_players
    json_players = REDIS.get('players')
    if json_players.present?
      JSON.parse(json_players)
    else
      []
    end
  end

  def self.add_player(game_data)
    player = create_player(game_data)
    players = get_players << player
    REDIS.set('players', players.to_json)
    player
  end

  def self.updated_player_for_move_event(game_data)
    updated_player = nil
    updated_players = Player.get_players.map do |player|
      if player['id'] == game_data['id']
        player = handleAcceleration(player, game_data['gameEvent']) if ['up', 'upStop'].include?(game_data['gameEvent'])
        player = handleRotation(player, game_data['gameEvent']) if ['left', 'right', 'leftStop', 'rightStop'].include?(game_data['gameEvent'])

        player = update_attributes(player, game_data)
        updated_player = player
      end
      player
    end
    REDIS.set('players', updated_players.to_json)
    updated_player
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

  def self.handle_fire(game_data)
    updated_player = nil
    updated_players = Player.get_players.map do |player|
      if player['id'] == game_data['id']
        player['fire'] = game_data['gameEvent'] == 'fire'
        player['lastFired'] = (Time.now.to_f * 1000).round if game_data['gameEvent'] == 'fireStop'

        player = update_attributes(player, game_data)
        updated_player = player
      end
      player
    end
    REDIS.set('players', updated_players.to_json)
    updated_player
  end

  def self.handleRotation(player, game_event)
    if (['leftStop', 'rightStop'].include?(game_event))
      player['rotate'] = 'none'
    else
      player['rotate'] = game_event
    end
    player
  end

  def self.explode_player(game_data)
    updated_player = nil
    updated_players = Player.get_players.map do |player|
      if player['id'] == game_data['id']
        player['lives'] = game_data['lives']
        player['hitpoints'] = game_data['hitpoints']
        player['lastEvent'] = game_data['gameEvent']

        player = update_attributes(player, game_data)
        updated_player = player
      end
      player
    end
    REDIS.set('players', updated_players.to_json)
    updated_player
  end

  def self.remove_player(userId)
    updated_players = get_players.reject { |player| player['id'] == userId }
    REDIS.set('players', updated_players.to_json)
    {id: userId, lastEvent: 'remove'}
  end

  def self.update_attributes(player, game_data)
    player['lastEvent'] = game_data['gameEvent']
    player['location'] = game_data['location']
    player['angle'] = game_data['angle']
    player['updatedAt'] = (Time.now.to_f * 1000).round
    player
  end
end
