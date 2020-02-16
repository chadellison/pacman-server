module Api
  module V1
    class TimeController < ApplicationController
      def index
        render json: GameTime.get_time_data(time_params[:sent_time].to_f)
      end

      private

      def time_params
        params.permit(:sent_time)
      end
    end
  end
end
