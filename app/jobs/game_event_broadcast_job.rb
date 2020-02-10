class GameEventBroadcastJob < ApplicationJob
  queue_as :default

  def perform(playerData)
    ActionCable
      .server
      .broadcast("game_data", {playerData: playerData})
  end
end
