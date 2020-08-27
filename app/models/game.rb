class Game
  def self.find_defense_data
    red_leaks = REDIS.get('red_leaks').to_i
    blue_leaks = REDIS.get('blue_leaks').to_i
    { red: 10 - red_leaks, blue: 10 - blue_leaks }
  end
end
