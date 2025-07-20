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
require 'rails_helper'

RSpec.describe Chord, type: :model do
  describe 'scope' do
    describe 'ordered' do
      it 'returns chords in order of position_in_measure' do
        chord1 = create(:chord, position: 1)
        chord2 = create(:chord, position: 2)
        expect(Chord.ordered).to eq([chord1, chord2])
      end
    end
  end
end 
