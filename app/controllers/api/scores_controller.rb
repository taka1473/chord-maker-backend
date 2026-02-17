class Api::ScoresController < ApplicationController
  SCORE_LIST_FIELDS = [ :id, :title, :artist, :key, :key_name, :tempo, :time_signature, :lyrics, :created_at, :published ].freeze
  SCORE_DETAIL_FIELDS = [ :id, :title, :artist, :key, :key_name, :tempo, :time_signature, :lyrics, :published ].freeze

  before_action :authenticate!, only: [ :create, :upsert_whole_score, :destroy ]
  before_action :authenticate_if_present, only: [ :whole_score ]
  before_action :set_score, only: [ :whole_score, :upsert_whole_score, :destroy ]
  before_action :authorize_score_owner!, only: [ :upsert_whole_score, :destroy ]

  def index
    direction = params[:sort] == "oldest" ? :asc : :desc
    scores = Score.published.includes(:tags).order(created_at: direction)
    scores = scores.search(params[:search]) if params[:search].present?
    scores = scores.by_tags(Array(params[:tags])) if params[:tags].present?
    render json: scores, only: SCORE_LIST_FIELDS, methods: [ :tag_names ]
  end

  def create
    score = Score.new(score_params.merge(user: current_user))
    if score.save
      render json: score,
        only: SCORE_LIST_FIELDS, methods: [ :tag_names ],
        status: :created
    else
      render json: { errors: score.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def whole_score
    unless @score.published? || @score.user_id == current_user&.id
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

  private

  def set_score
    @score = Score.includes(:tags, measures: :chords).find(params[:id])
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
