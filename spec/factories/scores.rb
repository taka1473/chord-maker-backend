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
FactoryBot.define do
  factory :score do
    association :user
    title { "Sample Song" }
    key_name { "A" }
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
