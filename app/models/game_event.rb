class GameEvent
  def self.handleEvent(game_event_data)
    case game_event_data['game_event']
    when 'start'
      json_players = REDIS.get('players')
      if json_players.present?
        players = JSON.parse(json_players)
        players << {game_event_data['playerId'] => 'start'}
      else
        players = [{game_event_data['playerId'] => 'start'}]
      end
      REDIS.set('players', players.to_json)
      GameEventBroadcastJob.perform_later(game_event)
    else
      REDIS.set(game_event_data['playerId'], 'start')
    end
  end
end
