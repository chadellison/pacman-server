class Player
  START_COORDINATES = {'x' => 35, 'y' => 35}
  VELOCITY = 5
  ANIMATION_FRAME_RATE = 30.0
  PLAYER_RADIUS = 25
  MOUTH_OPEN_VALUE = 40
  MOUTH_POSITION = 40

  def self.create_player(game_data)
    player = {
      'id' => game_data['id'],
      'name' => Faker::Name.name,
      'score' => 0,
      'location' => START_COORDINATES,
      'direction' => 'right',
      'velocity' => VELOCITY,
      'radius' => PLAYER_RADIUS,
      'mouthOpenValue' => MOUTH_OPEN_VALUE,
      'mouthPosition' => MOUTH_POSITION
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

    updated_player = nil
    time_stamp = (Time.now.to_f * 1000).round
    updated_players = players.map do |player|
      if player['id'] == game_data['id']
        player['direction'] = 'right'
        player['lastEvent'] = game_data['gameEvent']
        player['updatedAt'] = time_stamp
        updated_player = player
      end
      player
    end
    REDIS.set('players', updated_players.to_json)
    updated_player
  end

  def self.updated_player_for_move_event(game_data)
    updated_player = nil
    time_stamp = (Time.now.to_f * 1000).round
    updated_players = Player.get_players.map do |player|
      if player['id'] == game_data['id']
        player['direction'] = game_data['gameEvent']
        player['lastEvent'] = game_data['gameEvent']
        player['location'] = game_data['location']
        player['updatedAt'] = time_stamp
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
