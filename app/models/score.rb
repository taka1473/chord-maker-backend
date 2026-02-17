# == Schema Information
#
# Table name: scores
#
#  id                                  :bigint           not null, primary key
#  artist                              :string
#  key(0: A, 1: A#...)                 :integer          not null
#  key_name(distinguishing A# from Bb) :string           not null
#  lyrics                              :text
#  published                           :boolean          default(FALSE)
#  tempo                               :integer
#  time_signature                      :string
#  title                               :string           not null
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  user_id                             :bigint           not null
#
# Indexes
#
#  index_scores_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Score < ApplicationRecord
  KEY_MAP = {
    'A' => 0,
    'A#' => 1,
    'Bb' => 1,
    'B' => 2,
    'C' => 3,
    'C#' => 4,
    'Db' => 4,
    'D' => 5,
    'D#' => 6,
    'Eb' => 6,
    'E' => 7,
    'F' => 8,
    'F#' => 9,
    'Gb' => 9,
    'G' => 10,
    'G#' => 11,
    'Ab' => 11,
  }

  belongs_to :user
  has_many :measures, dependent: :destroy
  has_many :chords, through: :measures
  has_many :score_tags, dependent: :destroy
  has_many :tags, through: :score_tags
  
  validates :title, presence: true, length: { minimum: 1, maximum: 100 }
  validates :key, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 11 }
  validates :key_name, presence: true, inclusion: { in: KEY_MAP.keys }
  validates :tempo, numericality: { greater_than: 0, less_than: 500 }, allow_blank: true

  before_validation :set_key

  accepts_nested_attributes_for :measures, allow_destroy: true
  accepts_nested_attributes_for :chords, allow_destroy: true
  
  scope :published, -> { where(published: true) }
  scope :search, ->(query) {
    where("title ILIKE :q OR artist ILIKE :q", q: "%#{query}%")
  }
  scope :by_tags, ->(tag_names) {
    where(id: ScoreTag.joins(:tag)
      .where(tags: { name: tag_names })
      .group(:score_id)
      .having("COUNT(DISTINCT tags.name) = ?", tag_names.size)
      .select(:score_id))
  }

  def tag_names
    tags.pluck(:name)
  end

  def tag_names=(names)
    self.tags = Array(names).map(&:strip).reject(&:blank?).uniq.map do |name|
      Tag.find_or_create_by!(name: name)
    end
  end

  private

  def set_key
    self.key = KEY_MAP[key_name]
  end

  def key_name_respond_to_key
    return if KEY_MAP[key_name] == key

    errors.add(:key, "does not match the key name")
  end
end
