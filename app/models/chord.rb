# == Schema Information
#
# Table name: chords
#
#  id          :bigint           not null, primary key
#  bass_offset :integer          not null
#  order       :integer          not null
#  root_offset :integer          not null
#  type        :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  measure_id  :bigint           not null
#
# Indexes
#
#  index_chords_on_measure_id  (measure_id)
#
# Foreign Keys
#
#  fk_rails_...  (measure_id => measures.id)
#
class Chord < ApplicationRecord
  belongs_to :measure
  
  validates :name, presence: true, length: { minimum: 1, maximum: 10 }
  validates :position_in_measure, presence: true, numericality: { greater_than: 0 }
  validates :duration, numericality: { greater_than: 0 }, allow_blank: true
  
  scope :ordered, -> { order(:position_in_measure) }
  
  # Common chord types
  CHORD_TYPES = %w[
    major minor diminished augmented
    sus2 sus4 add9 maj7 min7 dom7
    dim7 aug7 maj9 min9 dom9
  ].freeze
  
  def display_name
    name
  end
  
  def major?
    !name.include?('m') && !name.include?('dim') && !name.include?('aug')
  end
  
  def minor?
    name.include?('m') && !name.include?('dim') && !name.include?('aug')
  end
  
  def seventh?
    name.include?('7')
  end
end 
