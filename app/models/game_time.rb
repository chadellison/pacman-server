class GameTime
  def self.get_time_data(start_time)
    difference = (Time.now.to_f * 1000) - Time.at(start_time).utc.to_f
    {difference: difference}
  end
end
