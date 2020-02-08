class Player
  def self.getPlayers
    json_players = REDIS.get('players')
    if json_players.present?
      JSON.parse(json_players)
    else
      []
    end
  end

  def self.createPlayer(game_data)
    player = {
      id: game_data['id'],
      location: {x: 35, y: 35},
      direction: 'right',
      updated_at: Time.now
    }
  end
end
