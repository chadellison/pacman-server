class GameEvent
  EVENT_DIVIDER = 200
  RANDOM_BUFF_INDEX_SIZE = 8

  def self.handle_event(game_data)
    case game_data['gameEvent']
    when 'start'
      player = Player.activate_player(game_data)
      GameEventBroadcastJob.perform_later(player)
    when 'explode'
      handle_explode_event(game_data)
    when 'leak'
      AiPlayer.handle_leak(game_data)
    when 'bombers'
      bombers = AiPlayer.deploy_bombers(game_data)
      GameEventBroadcastJob.perform_later(bombers)
    when 'supplyShip'
      supply_ship = AiPlayer.deploy_supply_ship
      GameEventBroadcastJob.perform_later(supply_ship)
    else
      player = Player.update_player(game_data)
      GameEventBroadcastJob.perform_later(player)
    end
  end

  def self.handle_explode_event(game_data)
    if game_data['type'] === 'human'
      game_data['updatedAt'] = (Time.now.to_f * 1000).round
      game_data['explodedAt'] = (Time.now.to_f * 1000).round
      players = Player.get_players
      if players[game_data['index']].present?
        players[game_data['index']] = game_data
        REDIS.set('players', players.to_json)
        GameEventBroadcastJob.perform_later(game_data)
      end
    else
      ai_ships = AiPlayer.get_ai_ships
      ai_ships.delete(game_data['id'].to_s)
      game_data['buffIndex'] = rand(RANDOM_BUFF_INDEX_SIZE) if game_data['type'] == 'supplyShip'
      game_data['updatedAt'] = (Time.now.to_f * 1000).round
      REDIS.set('ai_ships', ai_ships.to_json)
      GameEventBroadcastJob.perform_later(game_data)
    end
  end
end
