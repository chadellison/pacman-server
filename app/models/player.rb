class Player
  class << self
    def unsubscribe_player(user_id)
      players = Player.get_players
      player = players.detect { |player| player['userId'] == user_id }
      player['unsubscribed'] = true

      if players.all? { |p| p['unsubscribed'] }
        REDIS.flushall
      else
        player['explode'] = true
        player['gameEvent'] = 'explode'
        player['explodeAnimation'] = {x: 0, y: 0};
        player['updatedAt'] = (Time.now.to_f * 1000).round
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
      case player_data['gameEvent']
      when 'up'
        player['accelerate'] = true
        player['trajectory'] = player_data['trajectory']
      when 'upStop'
        player['accelerate'] = false
        player['trajectory'] = player_data['trajectory']
        player['lastAccelerationTime'] = (Time.now.to_f * 1000).round
      when 'left'
        player['rotate'] = 'left'
      when 'leftStop'
        player['rotate'] = 'none'
      when 'right'
        player['rotate'] = 'right'
      when 'rightStop'
        player['rotate'] = 'none'
      when 'shop'
        player['armor'] = player_data['armor']
        player['damage'] = player_data['damage']
        player['weaponIndex'] = player_data['weaponIndex']
        player['velocity'] = player_data['velocity']
        player['shipIndex'] = player_data['shipIndex']
        player['maxHitpoints'] = player_data['maxHitpoints']
      end

      player['gameEvent'] = player_data['gameEvent']
      player['kills'] = player_data['kills']
      player['location'] = player_data['location']
      player['angle'] = player_data['angle']
      player['hitpoints'] = player_data['hitpoints']
      player['gold'] = player_data['gold']
      player['score'] = player_data['score']
      player['items'] = player_data['items']
      player['effects'] = player_data['effects']
      player['killedBy'] = player_data['killedBy']
      player['updatedAt'] = (Time.now.to_f * 1000).round
      players[player['index']] = player
      REDIS.set('players', players.to_json)
      player
    end
  end
end
