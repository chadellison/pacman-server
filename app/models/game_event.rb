class GameEvent
  EVENT_DIVIDER = 100

  def self.handle_event(game_data)
    case game_data['gameEvent']
    when 'start'
      player = Player.add_player(game_data)
      GameEventBroadcastJob.perform_later(player)
    when 'remove'
      player = Player.remove_player(game_data['id'])
      GameEventBroadcastJob.perform_later(player)
    when 'leak'
      player = AiPlayer.handle_leak(game_data)
      GameEventBroadcastJob.perform_later(player) if player.present?
    else
      update_team_events(game_data['team'])
      update_total_events
      player = Player.update_player(game_data)
      GameEventBroadcastJob.perform_later(player)
    end
  end

  def self.update_team_events(team)
    team_event_count = REDIS.get(team + '_events').to_i
    team_event_count += 1
    if team_event_count > 0 && team_event_count % EVENT_DIVIDER == 0
      bombers = AiPlayer.deploy_bombers(team == 'red' ? 'blue' : 'red', team_event_count / EVENT_DIVIDER)
      GameEventBroadcastJob.perform_later(bombers)
    end
    REDIS.set(team + '_events', team_event_count)
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
end
