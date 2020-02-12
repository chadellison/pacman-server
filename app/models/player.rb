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

  def self.get_players_with_updated_timestamps(sent_time)
    time_stamp = Time.now.to_f * 1000
    latency_offset = (time_stamp - sent_time.to_f) * 2
    board = JSON.parse(REDIS.get('game'))['board']

    get_players.map do |player|
      elapsed_time = (time_stamp - player['updated_at']) + latency_offset
      distance = calculate_distance(elapsed_time, player['velocity'])
      update_player(player, board, time_stamp, player['location'], distance)
    end
  end

  def self.updated_players_for_start_event(game_data)
    player = create_player(game_data)
    players = get_players << player
    board = JSON.parse(REDIS.get('game'))['board']

    current_time = Time.now.to_f * 1000
    latency = current_time - game_data['sentTime']
    updated_players = players.map do |player|
      if player['id'] == game_data['id']
        start_location = player['location']
        player['latency'] = latency
      else
        start_location = game_data['playerLocations'][player['id'].to_s]
      end
      distance = calculate_distance(latency + player['latency'], player['velocity'])
      update_player(player, board, current_time, start_location, player['latency'] + latency)
    end
    REDIS.set('players', updated_players.to_json)
    updated_players
  end

  def self.updated_players_for_move_event(game_data)
    board = JSON.parse(REDIS.get('game'))['board']

    current_time = Time.now.to_f * 1000
    latency = current_time - game_data['sentTime']

    updated_players = Player.get_players.map do |player|
      if player['id'] == game_data['id']
        player['direction'] = game_data['gameEvent']
        player['latency'] = latency
      end
      distance = calculate_distance(latency + player['latency'], player['velocity'])
      location = game_data['playerLocations'][player['id'].to_s]
      update_player(player, board, current_time, location, distance)
    end
    REDIS.set('players', updated_players.to_json)
    updated_players
  end

  def self.update_player(player, board, time_stamp, location, distance)
    player['location'] = handle_location(
      player['direction'],
      location,
      distance,
      board['width'],
      board['height']
    )
    player['updated_at'] = time_stamp
    player
  end

  def self.calculate_distance(elapsed_time, velocity)
    game_time = elapsed_time / 5 / ANIMATION_FRAME_RATE
    (velocity * game_time).round
  end

  def self.handle_location(direction, location, distance, board_width, board_height)
    case direction
    when 'up' then handle_up(location, distance.round)
    when 'left' then handle_left(location, distance.round)
    when 'right' then handle_right(location, distance.round, board_width)
    when 'down' then handle_down(location, distance.round, board_height)
    end
  end

  def self.handle_up(location, distance)
    new_location = location['y'] - distance
    y = new_location <= PLAYER_RADIUS ? PLAYER_RADIUS : new_location
    {'x' => location['x'], 'y' => y }
  end

  def self.handle_left(location, distance)
    new_location = location['x'] - distance
    x = new_location <= PLAYER_RADIUS ? PLAYER_RADIUS : new_location
    {'x' => x, 'y' => location['y']}
  end

  def self.handle_right(location, distance, board_width)
    new_location = location['x'] + distance
    width_minus_radius = board_width - PLAYER_RADIUS
    x = new_location >= width_minus_radius ? width_minus_radius : new_location
    {'x' => x, 'y' => location['y']}
  end

  def self.handle_down(location, distance, board_height)
    new_location = location['y'] + distance
    height_minus_radius = board_height - PLAYER_RADIUS
    y = new_location >= height_minus_radius ? height_minus_radius : new_location
    {'x' => location['x'], 'y' => y}
  end

  def self.remove_player(userId)
    updated_players = get_players.reject { |player| player['id'] == userId }
    REDIS.set('players', updated_players.to_json)
  end
end
