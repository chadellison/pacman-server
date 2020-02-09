class Game
  DEFAULT_BOARD_WITH = 980
  DEFAULT_BOARD_HEIGHT = 665
  SQUARE_DISTANCE = 35;
  PACMAN_RADIUS = 25;

  def self.create_game
    game = {
      board: {
        width: DEFAULT_BOARD_WITH,
        height: DEFAULT_BOARD_HEIGHT,
        squares: default_squares
      }
    }
    REDIS.set('game', game.to_json)
  end

  def self.get_game
    json_game = REDIS.get('game')
    players = Player.get_players

    if json_game.present?
      game = JSON.parse(json_game)
    else
      game = create_game
    end
    { game: game, players: players }
  end

  def self.default_squares
    x = SQUARE_DISTANCE
    y = SQUARE_DISTANCE
    squares = {}
    while y <= DEFAULT_BOARD_HEIGHT do
      while x <= DEFAULT_BOARD_WITH do
        squares[x.to_s + ':' + y.to_s] = 1
        x += SQUARE_DISTANCE
      end
      squares[x.to_s + ':' + y.to_s] = 1
      x = SQUARE_DISTANCE
      y += SQUARE_DISTANCE
    end
    squares;
  end
end
