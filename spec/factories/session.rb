# == Schema Information
#
# Table name: sessions
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  ip_address :string
#  user_agent :string
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_sessions_on_token    (token) UNIQUE
#  index_sessions_on_user_id  (user_id)
#
FactoryBot.define do
  factory(:session) do
    user
    token { SecureRandom.base58(32) }
    ip_address { '127.0.0.1' }
    user_agent { 'RSpec Test Agent' }
  end
end
