# == Schema Information
#
# Table name: score_tags
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  score_id   :bigint           not null
#  tag_id     :bigint           not null
#
# Indexes
#
#  index_score_tags_on_score_id             (score_id)
#  index_score_tags_on_score_id_and_tag_id  (score_id,tag_id) UNIQUE
#  index_score_tags_on_tag_id               (tag_id)
#
# Foreign Keys
#
#  fk_rails_...  (score_id => scores.id)
#  fk_rails_...  (tag_id => tags.id)
#
class ScoreTag < ApplicationRecord
  belongs_to :score
  belongs_to :tag

  validates :tag_id, uniqueness: { scope: :score_id }
end
