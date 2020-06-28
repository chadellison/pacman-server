class AiPlayer
  def self.deploy_supply_ship
    players = Player.get_players
    id = generate_sequence
    supply_ship = {
      id: id,
      type: 'supplyShip',
      location: {x: 1800, y: 1125},
      angle: 1,
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
    players[id] = supply_ship
    REDIS.set('players', players.to_json)
    supply_ship
  end

  def self.deploy_bombers(team, count)
    players = Player.get_players
    bombers = []

    count.times do
      id = generate_sequence

      bomber = {
        id: id,
        type: 'bomber',
        location: team == 'red' ? {x: 0, y: rand(300..900)} : {x: 1800, y: rand(300..900)},
        angle: team == 'red' ? 0 : 180,
        accelerate: true,
        velocity: rand(1..3),
        effects: {},
        score: 0,
        armor: 1,
        trajectory: team == 'red' ? 0 : 180,
        rotate: 'none',
        hitpoints: 500,
        maxHitpoints: 500,
        gameEvent: 'bombers',
        team: team,
        explodeAnimation: {},
        updatedAt: (Time.now.to_f * 1000).round
      }
      bombers << bomber
      players[id] = bomber
    end

    REDIS.set('players', players.to_json)
    { gameEvent: 'bombers', bombers: bombers }
  end

  def self.generate_sequence
    sequence = REDIS.get('sequence').to_i
    sequence += 1
    REDIS.set('sequence', sequence)
    sequence
  end

  def self.handle_leak(game_data)
    players = Player.get_players
    players.delete(game_data['id'].to_s)

    leaks = REDIS.get(game_data['team'] + '_leaks').to_i + 1
    if leaks == 10
      Game.handle_game_over(game_data)
    else
      REDIS.set(game_data['team'] + '_leaks', leaks)
      REDIS.set('players', players.to_json)
      game_data
    end
  end
end
