# == Schema Information
#
# Table name: contacts
#
#  id         :integer          not null, primary key
#  body       :text             not null
#  category   :string           not null
#  email      :string
#  score_url  :string
#  status     :string           default("open"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_contacts_on_status  (status)
#
class Contact < ApplicationRecord
  CATEGORIES = %w[rights_violation bug other].freeze
  STATUSES = %w[open resolved].freeze
  BODY_MAX_LENGTH = 5000
  EMAIL_MAX_LENGTH = 255
  SCORE_URL_MAX_LENGTH = 500

  validates :category, presence: true, inclusion: { in: CATEGORIES, allow_blank: true }
  validates :body, presence: true, length: { maximum: BODY_MAX_LENGTH }
  validates :email, length: { maximum: EMAIL_MAX_LENGTH },
                    format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :score_url, length: { maximum: SCORE_URL_MAX_LENGTH }
  validates :status, inclusion: { in: STATUSES }
end
