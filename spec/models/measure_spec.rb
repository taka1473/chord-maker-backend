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
require 'rails_helper'

RSpec.describe Measure, type: :model do
  describe 'scope' do
    describe 'ordered' do
      it 'returns measures in order of position' do
        measure1 = create(:measure, position: 1)
        measure2 = create(:measure, position: 2)
        expect(Measure.ordered).to eq([measure1, measure2])
      end
    end
  end
end 
