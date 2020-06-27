class GameEvent
  EVENT_DIVIDER = 100

  def self.handle_event(game_data)
    case game_data['gameEvent']
    when 'start'
      player = Player.add_player(game_data)
    when 'remove'
      player = Player.remove_player(game_data['id'])
    when 'leak'
      player = AiPlayer.handle_leak(game_data)
    else
      handle_ai_players(game_data['team'])
      player = Player.update_player(game_data)
    end
    GameEventBroadcastJob.perform_later(player)
  end

  def self.handle_ai_players(team)
    team_event_count = REDIS.get(team).to_i
    team_event_count += 1
    if team_event_count > 0 && team_event_count % EVENT_DIVIDER == 0
      bombers = AiPlayer.deploy_bombers(team == 'red' ? 'blue' : 'red', REDIS.get(team).to_i / EVENT_DIVIDER)
      GameEventBroadcastJob.perform_later(bombers)
    end
    REDIS.set(team, team_event_count)

    event_count = REDIS.get('event_count').to_i
    event_count += 1
    if event_count % EVENT_DIVIDER == 0
      supply_ship = AiPlayer.deploy_supply_ship
      GameEventBroadcastJob.perform_later(supply_ship)
    end
    REDIS.set('event_count', event_count)
  end
end
