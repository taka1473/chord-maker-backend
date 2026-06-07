class Api::ScoresController < ApplicationController
  SCORE_LIST_FIELDS = [ :id, :slug, :title, :artist, :key, :key_name, :tempo, :time_signature, :lyrics, :created_at, :published ].freeze
  SCORE_DETAIL_FIELDS = [ :id, :slug, :title, :artist, :key, :key_name, :tempo, :time_signature, :lyrics, :published ].freeze
  PER_PAGE = 20

  before_action :authenticate_if_present, only: [ :create, :whole_score, :upsert_whole_score ]
  before_action :authenticate!, only: [ :destroy, :claim ]
  before_action :set_score, only: [ :whole_score, :upsert_whole_score, :destroy, :claim ]
  before_action :authorize_score_owner_or_guest!, only: [ :upsert_whole_score ]
  before_action :authorize_score_owner!, only: [ :destroy ]

  def index
    direction = params[:sort] == "oldest" ? :asc : :desc
    scores = Score.published.includes(:tags).order(created_at: direction)
    scores = scores.search(params[:search]) if params[:search].present?
    scores = scores.by_tags(Array(params[:tags])) if params[:tags].present?

    total_count = scores.count
    page = [ params[:page].to_i, 1 ].max
    scores = scores.limit(PER_PAGE).offset((page - 1) * PER_PAGE)

    render json: {
      scores: scores.as_json(only: SCORE_LIST_FIELDS, methods: [ :tag_names ]),
      total_count: total_count,
      page: page,
      per_page: PER_PAGE
    }
  end

  def create
    score = Score.new(score_params.merge(user: current_user))
    if score.save
      json = score.as_json(only: SCORE_LIST_FIELDS, methods: [ :tag_names ])
      json["guest_token"] = score.guest_token if score.guest?
      render json: json, status: :created
    else
      render json: { errors: score.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def whole_score
    if @score.published? || (current_user && @score.user_id == current_user.id)
      # public or owner: unrestricted
    elsif valid_guest_token?
      if @score.guest_expired?
        render json: { error: "This score has expired" }, status: :gone
        return
      end
    else
      render json: { error: "Score not found" }, status: :not_found
      return
    end
    render json: @score,
      only: SCORE_DETAIL_FIELDS, methods: [ :tag_names ],
      include: {
        measures: { only: [ :id, :position, :key, :key_name ],
        include: {
          chords: { only: [ :id, :root_offset, :bass_offset, :chord_type, :position ] } } } }
  end

  def upsert_whole_score
    @score.assign_attributes(whole_score_params)
    if @score.save
      render json: @score,
        only: SCORE_DETAIL_FIELDS, methods: [ :tag_names ],
        include: { measures: { only: [ :id, :position, :key, :key_name ], include: { chords: { only: [ :id, :root_offset, :bass_offset, :chord_type, :position ] } } } },
        status: :ok
    else
      render json: { errors: @score.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @score.destroy!
    head :no_content
  end

  def claim
    unless valid_guest_token?
      render json: { error: "Invalid or missing token" }, status: :forbidden
      return
    end

    @score.with_lock do
      if @score.user_id.present?
        render json: { error: "Score already has an owner" }, status: :unprocessable_entity
        return
      end

      if @score.guest_expired?
        render json: { error: "This score has expired" }, status: :gone
        return
      end

      @score.update!(user: current_user, guest_token: nil, guest_expires_at: nil)
      render json: @score.as_json(only: SCORE_LIST_FIELDS, methods: [ :tag_names ]), status: :ok
    end
  end

  private

  def set_score
    @score = Score.includes(:tags, measures: :chords).find_by!(slug: params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Score not found" }, status: :not_found
  end

  def score_params
    params.require(:score).permit(:title, :artist, :key_name, :tempo, :time_signature, :published, tag_names: [])
  end

  def whole_score_params
    params.require(:score).permit(:title, :artist, :key_name, :tempo, :time_signature, :published, tag_names: [], measures_attributes: [:id, :position, :key_name, :_destroy, chords_attributes: [:id, :root_offset, :bass_offset, :chord_type, :position, :_destroy]])
  end
end
