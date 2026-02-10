# == Schema Information
#
# Table name: measures
#
#  id         :bigint           not null, primary key
#  key        :integer
#  key_name   :string
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
