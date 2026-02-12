class Api::ScoresController < ApplicationController
  before_action :authenticate!, only: [ :create, :upsert_whole_score ]

  def index
    scores = Score.published.order(created_at: :desc)
    render json: scores, only: [ :id, :title, :key, :key_name, :tempo, :time_signature, :lyrics, :created_at, :published ]
  end

  def create
    score = Score.new(score_params.merge(user: current_user))
    if score.save
      render json: score,
        only: [ :id, :title, :key, :key_name, :tempo, :time_signature, :lyrics, :created_at, :published ],
        status: :created
    else
      render json: { errors: score.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def whole_score
    score = Score.includes(measures: :chords).find(params[:id])
    unless score.published? || owned_by_current_user?(score)
      render json: { error: 'Score not found' }, status: :not_found
      return
    end
    render json: score,
      only: [ :id, :title, :key, :key_name, :tempo, :time_signature, :lyrics, :published ],
      include: {
        measures: { only: [ :id, :position, :key, :key_name ],
        include: {
          chords: { only: [ :id, :root_offset, :bass_offset, :chord_type, :position ] } } } }
  end

  def upsert_whole_score
    score = Score.find(params[:id])
    score.assign_attributes(whole_score_params)
    if score.save
      render json: score,
        only: [ :id, :title, :key, :key_name, :tempo, :time_signature, :lyrics, :published ],
        include: { measures: { only: [ :id, :position, :key, :key_name ], include: { chords: { only: [ :id, :root_offset, :bass_offset, :chord_type, :position ] } } } },
        status: :ok
    else
      render json: { errors: score.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Score not found' }, status: :not_found
  end

  private

  def score_params
    params.require(:score).permit(:title, :key_name, :tempo, :time_signature, :published)
  end

  def whole_score_params
    params.require(:score).permit(:title, :key_name, :tempo, :time_signature, :published, measures_attributes: [:id, :position, :key_name, :_destroy, chords_attributes: [:id, :root_offset, :bass_offset, :chord_type, :position, :_destroy]])
  end

  def owned_by_current_user?(score)
    token = extract_token_from_header
    return false unless token
    payload = verify_firebase_token(token)
    return false unless payload
    user = User.find_by(account_id: payload["sub"])
    user&.id == score.user_id
  end
end
