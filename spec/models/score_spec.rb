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
require 'rails_helper'

RSpec.describe Score, type: :model do
  describe '#set_key (before_validation callback)' do
    let(:user) { create(:user) }

    context 'when key_name is provided and key is not set' do
      it 'sets key to 0 when key_name is A' do
        score = build(:score, user: user, key_name: 'A', key: nil)
        score.valid?
        expect(score.key).to eq(0)
      end

      it 'sets key to 1 when key_name is A#' do
        score = build(:score, user: user, key_name: 'A#', key: nil)
        score.valid?
        expect(score.key).to eq(1)
      end

      it 'sets key to 1 when key_name is Bb' do
        score = build(:score, user: user, key_name: 'Bb', key: nil)
        score.valid?
        expect(score.key).to eq(1)
      end

      it 'sets key to 2 when key_name is B' do
        score = build(:score, user: user, key_name: 'B', key: nil)
        score.valid?
        expect(score.key).to eq(2)
      end

      it 'sets key to 3 when key_name is C' do
        score = build(:score, user: user, key_name: 'C', key: nil)
        score.valid?
        expect(score.key).to eq(3)
      end

      it 'sets key to 4 when key_name is C#' do
        score = build(:score, user: user, key_name: 'C#', key: nil)
        score.valid?
        expect(score.key).to eq(4)
      end

      it 'sets key to 4 when key_name is Db' do
        score = build(:score, user: user, key_name: 'Db', key: nil)
        score.valid?
        expect(score.key).to eq(4)
      end

      it 'sets key to 5 when key_name is D' do
        score = build(:score, user: user, key_name: 'D', key: nil)
        score.valid?
        expect(score.key).to eq(5)
      end

      it 'sets key to 6 when key_name is D#' do
        score = build(:score, user: user, key_name: 'D#', key: nil)
        score.valid?
        expect(score.key).to eq(6)
      end

      it 'sets key to 6 when key_name is Eb' do
        score = build(:score, user: user, key_name: 'Eb', key: nil)
        score.valid?
        expect(score.key).to eq(6)
      end

      it 'sets key to 7 when key_name is E' do
        score = build(:score, user: user, key_name: 'E', key: nil)
        score.valid?
        expect(score.key).to eq(7)
      end

      it 'sets key to 8 when key_name is F' do
        score = build(:score, user: user, key_name: 'F', key: nil)
        score.valid?
        expect(score.key).to eq(8)
      end

      it 'sets key to 9 when key_name is F#' do
        score = build(:score, user: user, key_name: 'F#', key: nil)
        score.valid?
        expect(score.key).to eq(9)
      end

      it 'sets key to 9 when key_name is Gb' do
        score = build(:score, user: user, key_name: 'Gb', key: nil)
        score.valid?
        expect(score.key).to eq(9)
      end

      it 'sets key to 10 when key_name is G' do
        score = build(:score, user: user, key_name: 'G', key: nil)
        score.valid?
        expect(score.key).to eq(10)
      end

      it 'sets key to 11 when key_name is G#' do
        score = build(:score, user: user, key_name: 'G#', key: nil)
        score.valid?
        expect(score.key).to eq(11)
      end

      it 'sets key to 11 when key_name is Ab' do
        score = build(:score, user: user, key_name: 'Ab', key: nil)
        score.valid?
        expect(score.key).to eq(11)
      end
    end

    context 'when key_name is provided and key is already set' do
      it 'overwrites the existing key value based on key_name' do
        score = build(:score, user: user, key_name: 'C', key: 5)
        score.valid?
        expect(score.key).to eq(3) # C maps to 3, not 5
      end

      it 'overwrites incorrect key value with correct one from key_name' do
        score = build(:score, user: user, key_name: 'F#', key: 2)
        score.valid?
        expect(score.key).to eq(9) # F# maps to 9, not 2
      end
    end

    context 'when key_name is nil or invalid' do
      it 'sets key to nil when key_name is nil' do
        score = build(:score, user: user, key_name: nil, key: 5)
        score.valid?
        expect(score.key).to be_nil
      end

      it 'sets key to nil when key_name is not in KEY_MAP' do
        score = build(:score, user: user, key_name: 'InvalidKey', key: 5)
        score.valid?
        expect(score.key).to be_nil
      end
    end

    context 'callback timing' do
      it 'runs before validation, allowing the validation to pass' do
        score = build(:score, user: user, key_name: 'A', key: nil)
        expect(score).to be_valid
        expect(score.key).to eq(0)
      end

      it 'ensures key is set before key_name_respond_to_key validation runs' do
        score = build(:score, user: user, key_name: 'C', key: nil)
        expect(score).to be_valid
        expect(score.key).to eq(3)
        expect(score.errors).to be_empty
      end
    end
  end
end 
