class Api::Me::ScoresController < Api::Me::BaseController
  def index
    scores = current_user.scores.includes(:tags).order(created_at: :desc)
    render json: scores, only: [ :id, :slug, :title, :artist, :key, :key_name, :tempo, :time_signature, :lyrics, :created_at, :published ], methods: [ :tag_names ]
  end
end
