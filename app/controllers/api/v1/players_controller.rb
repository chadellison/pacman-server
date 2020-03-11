module Api
  module V1
    class PlayersController < ApplicationController
      def index
        render json: { players: Player.get_players }
      end
    end
  end
end
