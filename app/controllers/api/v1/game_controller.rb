module Api
  module V1
    class GameController < ApplicationController
      def index
        render json: Game.get_game(game_params[:sent_time])
      end

      private

      def game_params
        params.permit(:sent_time)
      end
    end
  end
end
