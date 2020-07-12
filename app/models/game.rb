class Game
  def self.find_defense_data
    red_leaks = REDIS.get('red_leaks').to_i
    blue_leaks = REDIS.get('blue_leaks').to_i
    { red: 10 - red_leaks, blue: 10 - blue_leaks }
  end

  def self.generate_sequence
    sequence = REDIS.get('sequence').to_i
    sequence += 1
    REDIS.set('sequence', sequence)
    sequence
  end

  def self.handle_game_over
    REDIS.set('ai_ships', {}.to_json)
    REDIS.set('sequence', 0)
    REDIS.set('event_count', 0)
    REDIS.set('red_last_send', 0)
    REDIS.set('blue_last_send', 0)
    REDIS.set('red_leaks', 0)
    REDIS.set('blue_leaks', 0)
    REDIS.set('red_sends', 0)
    REDIS.set('blue_sends', 0)
  end
end
