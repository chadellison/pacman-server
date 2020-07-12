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
end
