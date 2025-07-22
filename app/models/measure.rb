# == Schema Information
#
# Table name: measures
#
#  id         :bigint           not null, primary key
#  position   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  score_id   :bigint           not null
#
# Indexes
#
#  index_measures_on_score_id  (score_id)
#
# Foreign Keys
#
#  fk_rails_...  (score_id => scores.id)
#
class Measure < ApplicationRecord
  belongs_to :score
  has_many :chords, dependent: :destroy

  accepts_nested_attributes_for :chords, allow_destroy: true
  
  validates :position, presence: true, numericality: { greater_than: 0 }
  
  scope :ordered, -> { order(:position) }
end 
