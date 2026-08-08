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
FactoryBot.define do
  factory :contact do
    category { "other" }
    body { "お問い合わせ本文です" }
    email { nil }
    score_url { nil }
    status { "open" }
  end
end
