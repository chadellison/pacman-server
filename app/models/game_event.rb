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
    else
      update_team_events(game_data['team'])
      update_total_events
      player = Player.update_player(game_data)
      GameEventBroadcastJob.perform_later(player)
    end
  end

  def self.update_team_events(team)
    last_send = REDIS.get(team + '_last_send').to_i
    current_time = Time.now.to_i

    if current_time - last_send > 60
      count = REDIS.get(team + '_sends').to_i
      count += 1
      REDIS.set(team + '_sends', count)
      bombers = AiPlayer.deploy_bombers(team == 'red' ? 'blue' : 'red', count)
      GameEventBroadcastJob.perform_later(bombers)
      REDIS.set(team + '_last_send', current_time)
    end
  end

  def self.update_total_events
    event_count = REDIS.get('event_count').to_i
    event_count += 1
    if event_count % EVENT_DIVIDER == 0
      supply_ship = AiPlayer.deploy_supply_ship
      GameEventBroadcastJob.perform_later(supply_ship)
    end
    REDIS.set('event_count', event_count)
  end

  def self.handle_explode_event(game_data)
    if game_data['type'] === 'human'
      game_data['updatedAt'] = (Time.now.to_f * 1000).round
      game_data['explodedAt'] = (Time.now.to_f * 1000).round
      players = Player.get_players
      players[game_data['index']] = game_data
      REDIS.set('players', players.to_json)
      GameEventBroadcastJob.perform_later(game_data)
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
