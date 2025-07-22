class Api::ScoresController < ApplicationController
  def index
    scores = Score.all
    render json: scores, only: [ :id, :title, :key, :key_name, :tempo, :time_signature, :lyrics, :created_at ]
  end

  def create
    score = Score.new(score_params)
    if score.save
      render json: score, 
        only: [ :id, :title, :key, :key_name, :tempo, :time_signature, :lyrics, :created_at ],
        status: :created
    else
      render json: { errors: score.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def whole_score
    score = Score.includes(measures: :chords).find(params[:id])
    render json: score,
      only: [ :id, :title, :key, :key_name, :tempo, :time_signature, :lyrics],
      include: {
        measures: { only: [ :id, :position ],
        include: {
          chords: { only: [ :id, :root_offset, :bass_offset, :chord_type, :position ] } } } }
  end

  def upsert_whole_score
    score = Score.find(params[:id])
    score.assign_attributes(whole_score_params)
    if score.save
      render json: score,
        only: [ :id, :title, :key, :key_name, :tempo, :time_signature, :lyrics],
        include: { measures: { only: [ :id, :position ], include: { chords: { only: [ :id, :root_offset, :bass_offset, :chord_type, :position ] } } } },
        status: :ok
    else
      render json: { errors: score.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Score not found' }, status: :not_found
  end

  private

  def score_params
    params.require(:score).permit(:title, :key_name, :tempo, :time_signature, :lyrics, :user_id, :published)
  end

  def whole_score_params
    params.require(:score).permit(:title, :key_name, :tempo, :time_signature, :lyrics, :user_id, :published, measures_attributes: [:id, :position, :_destroy, chords_attributes: [:id, :root_offset, :bass_offset, :chord_type, :position, :_destroy]])
  end
end
