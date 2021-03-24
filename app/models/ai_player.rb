class AiPlayer
  def self.generate_sequece
    sequence = REDIS.get('sequence').to_i
    sequence += 1
    REDIS.set('sequence', sequence)
    sequence
  end

  def self.deploy_supply_ship
    {
      id: generate_sequece,
      type: 'supplyShip',
      name: 'supply ship',
      location: {x: 1800, y: 1125},
      angle: 1,
      active: true,
      effects: {},
      items: {},
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
  end

  def self.deploy_bombers(game_data)
    bombers = game_data['bombers'].map do |bomber|
      bomber[:id] = generate_sequece
      bomber[:location] = bomber['team'] == 'red' ? {x: rand(0..100), y: rand(300..900)} : {x: rand(1700..1800), y: rand(300..900)}
      bomber[:updatedAt] = (Time.now.to_f * 1000).round
      bomber
    end

    { gameEvent: 'bombers', bombers: bombers }
  end

  def self.handle_leak(game_data)
    leak = REDIS.get(game_data['id'])
    if leak.blank?
      leaks = REDIS.get(game_data['team'] + '_leaks').to_i + 1
      REDIS.set(game_data['team'] + '_leaks', leaks)
      game_data['defenseData'] = {
        red: 100 - REDIS.get('red_leaks').to_i,
        blue: 100 - REDIS.get('blue_leaks').to_i
      }
      REDIS.set(game_data['id'], true)
      GameEventBroadcastJob.perform_later(game_data)
      if leaks == 100
        Score.add_scores
        REDIS.flushall
      end
    end
  end
end
