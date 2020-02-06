class GameEventBroadcastJob < ApplicationJob
  queue_as :default

  def perform(gameEvent)
    ActionCable
      .server
      .broadcast("game_data", {gameData: 'here is data from the server'}.to_json)
  end
end
