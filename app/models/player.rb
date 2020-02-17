class Player
  START_COORDINATES = {'x' => 60, 'y' => 60}
  VELOCITY = 2
  ANIMATION_FRAME_RATE = 30.0

  def self.create_player(game_data)
    player = {
      'id' => game_data['id'],
      'name' => Faker::Name.name,
      'score' => 0,
      'location' => START_COORDINATES,
      'velocity' => VELOCITY,
      'angle' => 0,
      'isAccelerating' => false,
      'lastAccelerationTime' => 0,
      'lastEvent' => game_data['gameEvent'],
      'updatedAt' => (Time.now.to_f * 1000).round
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
        player['lastEvent'] = game_data['gameEvent']
        player['location'] = game_data['location']
        player['angle'] = game_data['angle']
        player['isAccelerating'] = true if game_data['gameEvent'] == 'up'
        player['isAccelerating'] = false if game_data['gameEvent'] == 'upStop'
        player['lastAccelerationTime'] = (Time.now.to_f * 1000).round if game_data['gameEvent'] == 'upStop'
        player['updatedAt'] = (Time.now.to_f * 1000).round
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
end
