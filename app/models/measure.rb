# == Schema Information
#
# Table name: measures
#
#  id         :bigint           not null, primary key
#  key        :integer
#  key_name   :string
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
  validates :key, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 11 }, allow_nil: true
  validates :key_name, inclusion: { in: Score::KEY_MAP.keys }, allow_nil: true

  before_validation :set_key

  scope :ordered, -> { order(:position) }

  private

  def set_key
    self.key = Score::KEY_MAP[key_name] if key_name.present?
  end
end
