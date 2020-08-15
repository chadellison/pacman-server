class Player
  class << self
    def unsubscribe_player(user_id)
      players = Player.get_players
      player = players.detect { |player| player['userId'] == user_id }
      player['unsubscribed'] = true

      if players.all? { |p| p['unsubscribed'] }
        REDIS.flushall
      else
        player['active'] = false
        player['gameEvent'] = 'explode'
        player['explodeAnimation'] = {coordinates: {x: 0, y: 0}};
        player['updatedAt'] = (Time.now.to_f * 1000).round
        player['explodedAt'] = (Time.now.to_f * 1000).round
        player['effects'] = {}
        players[player['index']] = player

        REDIS.set('players', players.to_json)
        GameEventBroadcastJob.perform_later(player)
      end
    end

    def get_players
      json_players = REDIS.get('players')
      if json_players.present?
        JSON.parse(json_players)
      else
        []
      end
    end

    def activate_player(game_data)
      players = get_players
      game_data['updatedAt'] = (Time.now.to_f * 1000).round
      game_data['index'] = players.size if game_data['index'].blank?

      players[game_data['index']] = game_data
      REDIS.set('players', players.to_json)
      game_data
    end

    def update_player(player_data)
      players = Player.get_players
      player = players[player_data['index'].to_i]
      if player.present? && player['active']
        player_data['updatedAt'] = (Time.now.to_f * 1000).round
        players[player_data['index'].to_i] = player_data
        REDIS.set('players', players.to_json)
        player_data
      end
    end
  end
end
