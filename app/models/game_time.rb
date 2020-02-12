class GameTime
  def self.get_time_data(sent_time)
    server_time = Time.now.to_f * 1000
    difference = server_time - sent_time
    difference *= -1 if difference < 0
    {serverTime: server_time, difference: difference}
  end
end
