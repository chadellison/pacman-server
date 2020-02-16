module Api
  module V1
    class TimeController < ApplicationController
      def index
        render json: GameTime.get_time_data(time_params[:start_time].to_f)
      end

      private

      def time_params
        params.permit(:start_time)
      end
    end
  end
end
