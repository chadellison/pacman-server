class Player
  def self.get_players
    json_players = REDIS.get('players')
    if json_players.present?
      JSON.parse(json_players)
    else
      []
    end
  end

  def self.get_players_with_updated_timestamps
    time_stamp = Time.now
    get_players.map do |player|
      player['location'] = calculateLocation(player)
      player['updated_at'] = time_stamp
      player
    end
  end

  def self.calculateLocation(player)
    difference_in_milliseconds = (Time.now - Time.new(player['updated_at'])) * 1000 / 30.0
    distance = (5 * difference_in_milliseconds).round
    case player['direction']
    when 'up'
      y = distance <= 25 ? 25 : distance
      location = {x: player['location']['x'], y: y }
    when 'left'
      x = distance <= 25 ? 25 : distance
      location = {x: x, y: player['location']['y']}
    when 'right'
      x = distance >= 980 - 25 ? 980 - 25 : distance
      location = {x: x, y: player['location']['y']}
    when 'down'
      y = distance >= 665 - 25 ? 665 - 25 : distance
      location = {x: player['location']['x'], y: y}
    end
  end

  def self.create_player(game_data)
    player = {
      'id' => game_data['id'],
      'location' => {x: 35, y: 35},
      'direction' => 'right',
      'updated_at' => Time.now.to_s
    }
  end
end
