class Game
  def self.find_defense_data
    red_leaks = REDIS.get('red_leaks').to_i
    blue_leaks = REDIS.get('blue_leaks').to_i
    { red: 10 - red_leaks, blue: 10 - blue_leaks }
  end

  def self.handle_game_over(game_data)
    players = Player.get_players.values.select { |player| player['type'] == 'human' }
    exploded_players = Player.get_exploaded_players.values
    game_data = { gameEvent: 'gameOver', gameOverStats: players + exploded_players }
    REDIS.set('players', {}.to_json)
    REDIS.set('exploded_players', {}.to_json)
    REDIS.set('sequence', 0)
    REDIS.set('event_count', 0)
    REDIS.set('red_events', 0)
    REDIS.set('blue_events', 0)
    REDIS.set('red_leaks', 0)
    REDIS.set('blue_leaks', 0)
    game_data
  end
end
