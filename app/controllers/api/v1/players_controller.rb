module Api
  module V1
    class PlayersController < ApplicationController
      def index
        render json: Player.getPlayers
      end
    end
  end
end
