class GameTime
  def self.get_time_data(time_params)
    client_difference = time_params[:sent_time].to_f - Time.at(time_params[:start_time].to_f / 1000).to_f
    server_difference = (Time.now.to_f * 1000) - Time.at(time_params[:start_time].to_f / 1000).to_f
    difference = client_difference - server_difference
    {difference: difference}
  end
end
