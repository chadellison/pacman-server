class Game
  DEFAULT_BOARD_WITH = 980
  DEFAULT_BOARD_HEIGHT = 665

  def self.create_game
    game = {
      board: {
        width: DEFAULT_BOARD_WITH,
        height: DEFAULT_BOARD_HEIGHT
      }
    }
    REDIS.set('game', game.to_json)
  end

  def self.get_game
    json_game = REDIS.get('game')

    if json_game.present?
      game = JSON.parse(json_game)
      players = Player.get_players
    else
      game = create_game
      players = []
    end
    { game: game, players: players }
  end
end
