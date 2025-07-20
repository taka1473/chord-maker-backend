# == Schema Information
#
# Table name: chords
#
#  id          :bigint           not null, primary key
#  bass_offset :integer          not null
#  chord_type  :string           default("0"), not null
#  position    :integer          not null
#  root_offset :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  measure_id  :bigint           not null
#
# Indexes
#
#  index_chords_on_measure_id  (measure_id)
#
# Foreign Keys
#
#  fk_rails_...  (measure_id => measures.id)
#
FactoryBot.define do
  factory :chord do
    association :measure
    sequence(:position) { |n| n }
    root_offset { 0 }
    bass_offset { 0 }
    chord_type { "major" }
  end
end 
