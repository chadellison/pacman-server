module Api
  module V1
    class PlayersController < ApplicationController
      def index
        render json: {
          players: Player.get_players.values,
          defenseData: Game.find_defense_data,
          userId: Game.generate_sequence
        }
      end
    end
  end
end
