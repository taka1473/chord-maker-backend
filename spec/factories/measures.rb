# == Schema Information
#
# Table name: measures
#
#  id         :bigint           not null, primary key
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
FactoryBot.define do
  factory :measure do
    association :score
    sequence(:position) { |n| n }

    trait :with_chords do
      after(:create) do |measure|
        create_list(:chord, 2, measure: measure)
      end
    end
  end
end 
