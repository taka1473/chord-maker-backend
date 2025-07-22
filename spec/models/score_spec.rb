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
  describe 'validations' do
    describe 'key_name_respond_to_key validation' do
      let(:user) { create(:user) }

      context 'when key and key_name match' do
        it 'is valid with A key (0) and A key_name' do
          score = build(:score, user: user, key: 0, key_name: 'A')
          expect(score).to be_valid
        end

        it 'is valid with A# key (1) and A# key_name' do
          score = build(:score, user: user, key: 1, key_name: 'A#')
          expect(score).to be_valid
        end

        it 'is valid with Bb key (1) and Bb key_name' do
          score = build(:score, user: user, key: 1, key_name: 'Bb')
          expect(score).to be_valid
        end

        it 'is valid with C key (3) and C key_name' do
          score = build(:score, user: user, key: 3, key_name: 'C')
          expect(score).to be_valid
        end

        it 'is valid with F# key (9) and F# key_name' do
          score = build(:score, user: user, key: 9, key_name: 'F#')
          expect(score).to be_valid
        end

        it 'is valid with Gb key (9) and Gb key_name' do
          score = build(:score, user: user, key: 9, key_name: 'Gb')
          expect(score).to be_valid
        end
      end

      context 'when key and key_name do not match' do
        it 'is invalid with A key (0) and B key_name' do
          score = build(:score, user: user, key: 0, key_name: 'B')
          expect(score).not_to be_valid
          expect(score.errors[:key]).to include('does not match the key name')
        end

        it 'is invalid with A# key (1) and C key_name' do
          score = build(:score, user: user, key: 1, key_name: 'C')
          expect(score).not_to be_valid
          expect(score.errors[:key]).to include('does not match the key name')
        end

        it 'is invalid with C key (3) and D key_name' do
          score = build(:score, user: user, key: 3, key_name: 'D')
          expect(score).not_to be_valid
          expect(score.errors[:key]).to include('does not match the key name')
        end

        it 'is invalid with F# key (9) and A# key_name' do
          score = build(:score, user: user, key: 9, key_name: 'A#')
          expect(score).not_to be_valid
          expect(score.errors[:key]).to include('does not match the key name')
        end
      end

      context 'edge cases' do
        it 'handles enharmonic equivalents correctly (A# vs Bb both map to key 1)' do
          score1 = build(:score, user: user, key: 1, key_name: 'A#')
          score2 = build(:score, user: user, key: 1, key_name: 'Bb')
          
          expect(score1).to be_valid
          expect(score2).to be_valid
        end

        it 'handles other enharmonic equivalents correctly (F# vs Gb both map to key 9)' do
          score1 = build(:score, user: user, key: 9, key_name: 'F#')
          score2 = build(:score, user: user, key: 9, key_name: 'Gb')
          
          expect(score1).to be_valid
          expect(score2).to be_valid
        end
      end
    end
  end
end 
