class GameTime
  def self.get_time_data(sent_time)
    difference = (Time.now.to_f * 1000) - Time.at(sent_time).utc.to_f
    { difference: difference }
  end
end
