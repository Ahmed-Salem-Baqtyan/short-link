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
#  index_short_urls_on_code     (code) UNIQUE
#  index_short_urls_on_user_id  (user_id)
#

class ShortUrl < ApplicationRecord
  # Constants
  SHORT_LINKS_LIMIT = 100

  # Associations
  belongs_to :user

  # belongs_to :user, optional: true

  # Validations
  validate :validate_url
  validates :url, presence: true
  validates :code, uniqueness: true, on: :update
  validate :validate_links_limit, on: :create

  # Callbacks
  before_validation :normalize_url
  after_create :set_short_code

  private

  def validate_links_limit
    if user.short_urls.count >= SHORT_LINKS_LIMIT
      errors.add(:base, "You have reached the limit of short links, please upgrade to a paid plan to create more links.")
    end
  end

  def normalize_url
    self.url = url&.strip
  end

  def validate_url
    return if url.blank?

    errors.add(:url, 'is not a valid URL') unless Url.new(url).valid?
  end

  def set_short_code
    update!(code: HASHIDS.encode(id))
  end
end
