module Api
  module V1
    class GameController < ApplicationController
      def index
        render json: Game.get_game(game_params[:sentTime])
      end

      private

      def game_params
        params.permit(:sentTime)
      end
    end
  end
end
