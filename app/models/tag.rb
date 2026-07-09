# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tags_on_name  (name) UNIQUE
#
class Tag < ApplicationRecord
  has_many :score_tags, dependent: :destroy
  has_many :scores, through: :score_tags

  validates :name, presence: true, uniqueness: true, length: { maximum: 40 }

  def self.suggest(query, limit: 8)
    q = query.to_s.strip.downcase
    return [] if q.length < 2

    joins(:scores)
      .where(scores: { published: true })
      .where("LOWER(tags.name) LIKE ?", "%#{sanitize_sql_like(q)}%")
      .distinct
      .limit(20)
      .pluck(:name)
      .sort_by { |name| [ name.downcase.start_with?(q) ? 0 : 1, name.downcase ] }
      .first(limit)
  end
end
