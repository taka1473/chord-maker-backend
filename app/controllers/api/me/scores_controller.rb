class Api::Me::ScoresController < Api::Me::BaseController
  def index
    scores = current_user.scores.order(created_at: :desc)
    render json: scores, only: [ :id, :title, :artist, :key, :key_name, :tempo, :time_signature, :lyrics, :created_at, :published ]
  end
end
