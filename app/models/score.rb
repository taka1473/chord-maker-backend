# == Schema Information
#
# Table name: scores
#
#  id             :bigint           not null, primary key
#  key            :string           not null
#  lyrics         :text
#  published      :boolean          default(FALSE)
#  tempo          :integer          not null
#  time_signature :string           not null
#  title          :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :bigint           not null
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
  validates :artist, length: { maximum: 100 }, allow_blank: true
  validates :key, inclusion: { in: %w[C C# D D# E F F# G G# A A# B Cm C#m Dm D#m Em Fm F#m Gm G#m Am A#m Bm] }, allow_blank: true
  validates :tempo, numericality: { greater_than: 0, less_than: 500 }, allow_blank: true
  
  scope :published, -> { where(published: true) }
end 
