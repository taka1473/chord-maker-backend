class Api::Admin::ScoresController < Api::Admin::BaseController
  SCORE_FIELDS = [ :id, :slug, :title, :artist, :key, :key_name, :tempo, :time_signature, :published, :created_at ].freeze
  PER_PAGE = 20

  def index
    scores = Score.includes(:user, :tags).order(created_at: :desc)

    total_count = scores.count
    page = [ params[:page].to_i, 1 ].max
    scores = scores.limit(PER_PAGE).offset((page - 1) * PER_PAGE)

    render json: {
      scores: scores.map { |s|
        s.as_json(only: SCORE_FIELDS, methods: [ :tag_names ])
         .merge("user" => s.user&.as_json(only: [ :id, :name ]))
      },
      total_count: total_count,
      page: page,
      per_page: PER_PAGE
    }
  end

  def unpublish
    score = Score.find(params[:id])
    score.update!(published: false)
    head :no_content
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Score not found" }, status: :not_found
  end

  def destroy
    score = Score.find(params[:id])
    score.destroy!
    head :no_content
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Score not found" }, status: :not_found
  end
end
