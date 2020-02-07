class GameEventBroadcastJob < ApplicationJob
  queue_as :default

  def perform(gameData)
    ActionCable
      .server
      .broadcast("game_data", {gameData: gameData})
  end
end
