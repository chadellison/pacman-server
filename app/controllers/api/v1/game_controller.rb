module Api
  module V1
    class GameController < ApplicationController
      def index
        render json: Game.get_game(params[:sentTime])
      end

      params.permit(:sentTime)
    end
  end
end
