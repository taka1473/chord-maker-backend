# == Schema Information
#
# Table name: scores
#
#  id                                  :bigint           not null, primary key
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
  belongs_to :user
  has_many :measures, dependent: :destroy
  
  validates :title, presence: true, length: { minimum: 1, maximum: 100 }
  validates :key, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 11 }
  validates :tempo, numericality: { greater_than: 0, less_than: 500 }, allow_blank: true
  
  scope :published, -> { where(published: true) }
end 
