# == Schema Information
#
# Table name: scores
#
#  id                                                                                 :bigint           not null, primary key
#  key(0: A, 1: A#, 2: B, 3: C, 4: C#, 5: D, 6: D#, 7: E, 8: F, 9: F#, 10: G, 11: G#) :integer          not null
#  key_name(distinguishing A# from Bb)                                                :string           not null
#  lyrics                                                                             :text
#  published                                                                          :boolean          default(FALSE)
#  tempo                                                                              :integer          not null
#  time_signature                                                                     :string           not null
#  title                                                                              :string           not null
#  created_at                                                                         :datetime         not null
#  updated_at                                                                         :datetime         not null
#  user_id                                                                            :bigint           not null
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
end 
