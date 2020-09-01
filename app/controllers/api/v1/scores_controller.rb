module Api
  module V1
    class ScoresController < ApplicationController
      def index
        render json: Score.get_scores
      end
    end
  end
end
