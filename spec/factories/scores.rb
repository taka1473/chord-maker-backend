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
FactoryBot.define do
  factory :score do
    association :user
    title { "Sample Song" }
    key_name { "A" }
    key_mode { "major" }
    tempo { 120 }
    time_signature { "4/4" }
    published { false }
    lyrics { "Sample lyrics for the song" }

    trait :published do
      published { true }
    end

    trait :with_measures do
      after(:create) do |score|
        create_list(:measure, 3, score: score)
      end
    end
  end
end 
