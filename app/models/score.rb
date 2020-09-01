class Score < ApplicationRecord
  def self.add_scores
    players = Player.get_players

    players.each do |player|
      Score.create(score: player['score'], name: player['name'])
    end
  end

  def self.get_scores
    Score.order(score: :desc).limit(100)
  end
end
