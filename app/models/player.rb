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
      'mouthPosition' => MOUTH_POSITION,
      'latencyOffset' => find_latency_offset(Time.now.utc.to_f, game_data['sentTime'])
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
    time_stamp = Time.now.utc.to_f
    board = JSON.parse(REDIS.get('game'))['board']

    latency_offset = find_latency_offset(time_stamp, sent_time)
    get_players.map do |player|
      elapsed_time = (time_stamp - player['updated_at']) + latency_offset

      distance = calculate_distance(elapsed_time, player['velocity'])
      player['location'] = handle_location(
        player['direction'],
        player['location'],
        distance,
        board['width'],
        board['height']
      )
      player['updated_at'] = time_stamp
      player
    end
  end

  def self.find_latency_offset(current_timestamp, sent_time)
    current_timestamp - (sent_time.to_f / 1000.0)
  end

  def self.updated_players_for_start_event(game_data)
    player = create_player(game_data)
    players = get_players << player
    board = JSON.parse(REDIS.get('game'))['board']

    time_stamp = Time.now.utc.to_f
    updated_players = players.map do |player|
      if player['id'] == game_data['id']
        start_location = player['location']
      else
        start_location = game_data['playerLocations'][player['id'].to_s]
      end
      update_player(player, board, time_stamp, start_location)
      player['updated_at'] = time_stamp
      player
    end
    REDIS.set('players', updated_players.to_json)
    updated_players
  end

  def self.updated_players_for_move_event(game_data)
    board = JSON.parse(REDIS.get('game'))['board']
    time_stamp = Time.now.utc.to_f
    updated_players = Player.get_players.map do |player|
      if player['id'] == game_data['id']
        player['direction'] = game_data['gameEvent']
        player['latencyOffset'] = find_latency_offset(time_stamp, game_data['sentTime'])
      end
      location = game_data['playerLocations'][player['id'].to_s]
      update_player(player, board, time_stamp, location)
    end
    REDIS.set('players', updated_players.to_json)
    updated_players
  end

  def self.update_player(player, board, time_stamp, location)
    distance = calculate_distance(player['latencyOffset'] * 2, player['velocity'])
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

  def self.calculate_distance(difference_in_milliseconds, velocity)
    elapsed_time = difference_in_milliseconds * 1000 / ANIMATION_FRAME_RATE
    (velocity * elapsed_time).round
  end

  def self.handle_location(direction, location, distance, board_width, board_height)
    case direction
    when 'up' then handle_up(location, distance)
    when 'left' then handle_left(location, distance)
    when 'right' then handle_right(location, distance, board_width)
    when 'down' then handle_down(location, distance, board_height)
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
