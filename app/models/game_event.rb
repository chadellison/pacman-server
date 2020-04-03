class GameEvent
  EVENT_DIVIDER = 100

  def self.handle_event(game_data)
    case game_data['gameEvent']
    when 'start'
      player = Player.add_player(game_data)
    when 'remove'
      player = Player.remove_player(game_data['id'])
    else
      handle_event_count
      player = Player.update_player(game_data)
    end
    GameEventBroadcastJob.perform_later(player)
  end

  def self.handle_event_count
    event_count = REDIS.get('event_count').to_i
    event_count += 1
    player_size = Player.get_players.values.size
    if event_count > (EVENT_DIVIDER * player_size)
      event_count = 0
      supply_ship = Player.deploy_supply_ship
      GameEventBroadcastJob.perform_later(supply_ship)
    end
    REDIS.set('event_count', event_count)
  end
end
