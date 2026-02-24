# == Schema Information
#
# Table name: chords
#
#  id          :bigint           not null, primary key
#  bass_offset :integer          not null
#  chord_type  :string           default("0"), not null
#  position    :integer          not null
#  root_offset :integer          not null
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
  CHORD_TYPES = %w[
    major minor 7 maj7 min7 min7-5
    dim dim7 aug sus2 sus4 add9
  ].freeze

  belongs_to :measure
  
  validates :position, presence: true, numericality: { greater_than: 0 }
  validates :root_offset, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 11 }
  validates :bass_offset, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 11 }
  validates :chord_type, presence: true, inclusion: { in: CHORD_TYPES }
  
  scope :ordered, -> { order(:position) }  
end 
