module Api
  module V1
    class PlayersController < ApplicationController
      def index
        render json: Player.get_players_with_updated_timestamps
      end
    end
  end
end
