module Api
  module V1
    class GameController < ApplicationController
      def index
        render json: Game.get_game
      end
    end
  end
end
