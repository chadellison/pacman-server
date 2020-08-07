class AiPlayer
  def self.deploy_supply_ship
    ai_ships = get_ai_ships
    id = Game.generate_sequence
    supply_ship = {
      id: id,
      type: 'supplyShip',
      location: {x: 1800, y: 1125},
      angle: 1,
      active: true,
      effects: {},
      score: 0,
      armor: rand(6),
      trajectory: rand(360),
      rotate: 'left',
      hitpoints: 500,
      maxHitpoints: 500,
      gameEvent: 'supplyShip',
      explodeAnimation: {},
      updatedAt: (Time.now.to_f * 1000).round
    }
    ai_ships[id] = supply_ship
    REDIS.set('ai_ships', ai_ships.to_json)
    supply_ship
  end

  def self.get_ai_ships
    json_ships = REDIS.get('ai_ships')
    if json_ships.present?
      JSON.parse(json_ships)
    else
      {}
    end
  end

  def self.deploy_bombers(game_data)
    ai_ships = get_ai_ships
    bombers = []

    game_data['bombers'].each do |bomber|
      id = Game.generate_sequence
      bomber[:id] = id
      bomber[:location] = bomber['team'] == 'red' ? {x: rand(0..100), y: rand(300..900)} : {x: rand(1700..1800), y: rand(300..900)}
      bomber[:angle] = bomber['team'] == 'red' ? 0 : 180
      bomber[:trajectory] = bomber['team'] == 'red' ? 0 : 180
      bomber[:updatedAt] = (Time.now.to_f * 1000).round
      bombers << bomber
      ai_ships[id] = bomber
    end

    REDIS.set('ai_ships', ai_ships.to_json)
    { gameEvent: 'bombers', bombers: bombers }
  end

  def self.handle_leak(game_data)
    ai_ships = get_ai_ships
    leak = ai_ships.delete(game_data['id'].to_s)
    if leak.present?
      leaks = REDIS.get(game_data['team'] + '_leaks').to_i + 1
      REDIS.set(game_data['team'] + '_leaks', leaks)
      REDIS.set('ai_ships', ai_ships.to_json)
      game_data['defenseData'] = {
        red: 10 - REDIS.get('red_leaks').to_i,
        blue: 10 - REDIS.get('blue_leaks').to_i
      }
      GameEventBroadcastJob.perform_later(game_data)
      REDIS.flushall if leaks == 10
    end
  end
end
