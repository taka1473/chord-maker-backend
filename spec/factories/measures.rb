# == Schema Information
#
# Table name: measures
#
#  id               :integer          not null, primary key
#  key              :integer
#  key_mode         :string
#  key_name         :string
#  position         :integer          not null
#  row_break_before :boolean          default(FALSE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  score_id         :bigint           not null
#
# Indexes
#
#  index_measures_on_score_id  (score_id)
#
# Foreign Keys
#
#  score_id  (score_id => scores.id)
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
