# == Schema Information
#
# Table name: short_urls
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  url        :text
#  code       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_short_urls_on_code              (code) UNIQUE
#  index_short_urls_on_user_id           (user_id)
#  index_short_urls_on_user_id_and_code  (user_id,code)
#
FactoryBot.define do
  factory(:short_url) do
    user { create(:user) }
    url { 'https://example.com' }
    code { 'ABC123' }
  end
end
