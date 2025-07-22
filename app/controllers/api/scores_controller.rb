class Api::ScoresController < ApplicationController
  def index
    scores = Score.all
    render json: scores, only: [ :id, :title, :key, :key_name, :tempo, :time_signature, :lyrics, :created_at ]
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
end
