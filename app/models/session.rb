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

class Session < ApplicationRecord
  # Associations
  belongs_to :user

  # Callbacks
  before_validation :generate_token, on: :create

  private

  def generate_token
    self.token = SecureRandom.base58(32)
  end
end
