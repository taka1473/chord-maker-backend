# == Schema Information
#
# Table name: chords
#
#  id          :integer          not null, primary key
#  bass_offset :integer          not null
#  chord_type  :string           default("0"), not null
#  position    :integer          not null
#  root_offset :integer          not null
#  tensions    :json             not null
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
#  measure_id  (measure_id => measures.id)
#
class Chord < ApplicationRecord
  CHORD_TYPES = %w[
    major minor 7
    6 min6
    maj7 min7 min7-5 minmaj7
    maj9 min9
    add9
    dim dim7
    aug aug7
    sus2 sus4 7sus4
  ].freeze

  # テンション（chord_type とは独立に加算するラベル）。表記スタイル非依存の正規キー。
  # 度数昇順で保持し、表示側もこの順に正規化する。
  TENSIONS = %w[b9 9 #9 11 #11 b13 13].freeze

  belongs_to :measure

  validates :position, presence: true, numericality: { greater_than: 0 }
  validates :root_offset, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 11 }
  validates :bass_offset, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 11 }
  validates :chord_type, presence: true, inclusion: { in: CHORD_TYPES }
  validate :validate_tensions

  before_validation :normalize_tensions

  scope :ordered, -> { order(:position) }

  private

  # 重複を除去し、配列以外は空配列に丸める。順序はそのまま（表示側で正規化）。
  def normalize_tensions
    self.tensions = tensions.is_a?(Array) ? tensions.uniq : []
  end

  def validate_tensions
    invalid = Array(tensions) - TENSIONS
    errors.add(:tensions, :inclusion) if invalid.any?
  end
end

