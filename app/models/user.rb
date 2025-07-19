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
class User < ApplicationRecord
  has_many :scores, dependent: :destroy
  
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
end 
