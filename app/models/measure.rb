# == Schema Information
#
# Table name: measures
#
#  id         :bigint           not null, primary key
#  order      :integer          not null
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
  
  validates :position, presence: true, numericality: { greater_than: 0 }
  validates :time_signature, format: { with: /\A\d+\/\d+\z/, message: "must be in format like 4/4" }, allow_blank: true
  
  scope :ordered, -> { order(:position) }
end 
