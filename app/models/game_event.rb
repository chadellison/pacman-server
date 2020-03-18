class GameEvent
  def self.handle_event(game_data)
    case game_data['gameEvent']
    when 'start'
      player = Player.add_player(game_data)
    when 'remove'
      player = Player.remove_player(game_data['id'])
    else
      player = Player.update_player(game_data)
    end
    GameEventBroadcastJob.perform_later(player)
  end
end
