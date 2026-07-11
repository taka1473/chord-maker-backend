# == Schema Information
#
# Table name: scores
#
#  id               :integer          not null, primary key
#  artist           :string
#  guest_expires_at :datetime
#  guest_token      :string
#  key              :integer          not null
#  key_mode         :string           default("major"), not null
#  key_name         :string           not null
#  lyrics           :text
#  published        :boolean          default(FALSE)
#  slug             :string           not null
#  tempo            :integer
#  time_signature   :string
#  title            :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :bigint
#
# Indexes
#
#  index_scores_on_guest_token  (guest_token) UNIQUE
#  index_scores_on_slug         (slug) UNIQUE
#  index_scores_on_user_id      (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
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

  belongs_to :user, optional: true
  has_many :measures, -> { order(:position) }, dependent: :destroy
  has_many :chords, through: :measures
  has_many :score_tags, dependent: :destroy
  has_many :tags, through: :score_tags

  validates :title, presence: true, length: { minimum: 1, maximum: 100 }
  validates :slug, presence: true, uniqueness: true
  KEY_MODES = %w[major minor].freeze

  validates :key, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 11 }
  validates :key_name, presence: true, inclusion: { in: KEY_MAP.keys }
  validates :key_mode, presence: true, inclusion: { in: KEY_MODES }
  validates :tempo, numericality: { greater_than: 0, less_than: 500 }, allow_blank: true
  validate :user_or_guest_token_present
  validate :validate_tag_names

  before_validation :set_key
  before_validation :generate_slug, on: :create
  before_validation :generate_guest_token, on: :create, if: -> { user.nil? }
  before_validation :set_guest_expires_at, on: :create, if: -> { user.nil? }
  before_save :assign_pending_tags

  accepts_nested_attributes_for :measures, allow_destroy: true
  accepts_nested_attributes_for :chords, allow_destroy: true
  
  scope :published, -> { where(published: true) }
  scope :expired_guests, -> { where(user_id: nil).where("guest_expires_at < ?", Time.current) }

  def guest?
    user_id.nil?
  end

  def guest_expired?
    guest_expires_at.nil? || guest_expires_at.past?
  end
  scope :search, ->(query) {
    where("title LIKE :q OR artist LIKE :q", q: "%#{query}%")
  }
  scope :by_tags, ->(tag_names) {
    where(id: ScoreTag.joins(:tag)
      .where(tags: { name: tag_names })
      .group(:score_id)
      .having("COUNT(DISTINCT tags.name) = ?", tag_names.size)
      .select(:score_id))
  }

  def tag_names
    @tag_names_assigned ? @pending_tag_names : tags.pluck(:name)
  end

  # 生のタグ名を保持するだけ（DB には書き込まない）。
  # 実際のタグ作成・関連付けは validation 通過後に before_save で行う。
  def tag_names=(names)
    @pending_tag_names = Array(names).map { |name| name.to_s.strip }.reject(&:blank?).uniq
    @tag_names_assigned = true
  end

  private

  def validate_tag_names
    return unless @tag_names_assigned

    @pending_tag_names.each do |name|
      if name.length > Tag::NAME_MAX_LENGTH
        errors.add(:tags, :too_long, name: name, count: Tag::NAME_MAX_LENGTH)
      end
    end
  end

  def assign_pending_tags
    return unless @tag_names_assigned

    self.tags = @pending_tag_names.map { |name| Tag.find_or_create_by(name: name) }
    @tag_names_assigned = false
  end

  def set_key
    self.key = KEY_MAP[key_name]
  end

  def generate_slug
    return if slug.present?

    base = title.to_s.parameterize.presence || "score"
    loop do
      self.slug = "#{base}-#{SecureRandom.alphanumeric(6).downcase}"
      break unless Score.exists?(slug: slug)
    end
  end

  def key_name_respond_to_key
    return if KEY_MAP[key_name] == key

    errors.add(:key, "does not match the key name")
  end

  def user_or_guest_token_present
    return if user_id.present? || guest_token.present?

    errors.add(:base, "must have a user or a guest token")
  end

  def generate_guest_token
    return if guest_token.present?

    loop do
      self.guest_token = SecureRandom.urlsafe_base64(32)
      break unless Score.exists?(guest_token: guest_token)
    end
  end

  def set_guest_expires_at
    self.guest_expires_at ||= 30.days.from_now
  end
end
