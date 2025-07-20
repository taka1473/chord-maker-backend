# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :string           not null
#
# Indexes
#
#  index_users_on_account_id  (account_id) UNIQUE
#
require 'rails_helper'

RSpec.describe User, type: :model do
end 
