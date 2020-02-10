class Player
  START_COORDINATES = {'x' => 35, 'y' => 35}
  VELOCITY = 5
  ANIMATION_FRAME_RATE = 30.0
  PLAYER_RADIUS = 25
  MOUTH_OPEN_VALUE = 40
  MOUTH_POSITION = 40

  def self.calculateLocation(player, board)
    elapsed_time = (Time.now.to_f - player['updated_at']) * 1000 / ANIMATION_FRAME_RATE
    distance = (player['velocity'] * elapsed_time).round
    case player['direction']
    when 'up'
      y = distance <= PLAYER_RADIUS ? PLAYER_RADIUS : distance
      location = {'x' => player['location']['x'], 'y' => y }
    when 'left'
      x = distance <= PLAYER_RADIUS ? PLAYER_RADIUS : distance
      location = {'x' => x, 'y' => player['location']['y']}
    when 'right'
      width_minus_radius = board['width'] - PLAYER_RADIUS
      x = distance >= width_minus_radius ? width_minus_radius : distance
      location = {'x' => x, 'y' => player['location']['y']}
    when 'down'
      height_minus_radius = board['height'] - PLAYER_RADIUS
      y = distance >= height_minus_radius ? height_minus_radius : distance
      location = {'x' => player['location']['x'], 'y' => y}
    end
  end

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

  def self.get_players_with_updated_timestamps
    time_stamp = Time.now.to_f
    game = JSON.parse(REDIS.get('game'))
    get_players.map do |player|
      player['location'] = calculateLocation(player, game['board'])
      player['updated_at'] = time_stamp
      player
    end
  end

  def self.updated_players_for_start_event(game_data)
    player = create_player(game_data)
    players = get_players << player

    time_stamp = Time.now.to_f
    updated_players = players.map do |player|
      if player['id'] == game_data['id']
        player['location'] = player['location']
      else
        player['location'] = game_data['playerLocations'][player['id'].to_s]
      end
      player['updated_at'] = time_stamp
      player
    end
    REDIS.set('players', updated_players.to_json)
    updated_players
  end

  def self.updated_players_for_move_event(game_data)
    time_stamp = Time.now.to_f
    updated_players = Player.get_players.map do |player|
      if player['id'] == game_data['id']
        player['direction'] = game_data['gameEvent']
      end
      player['location'] = game_data['playerLocations'][player['id'].to_s]
      player['updated_at'] = time_stamp
      player
    end
    REDIS.set('players', updated_players.to_json)
    updated_players
  end

  def self.remove_player(userId)
    updated_players = get_players.reject { |player| player['id'] == userId }
    REDIS.set('players', updated_players.to_json)
  end
end
