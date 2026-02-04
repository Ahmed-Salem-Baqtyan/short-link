# == Schema Information
#
# Table name: short_urls
#
#  id         :integer          not null, primary key
#  url        :text
#  code       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_short_urls_on_code  (code) UNIQUE
#

class ShortUrl < ApplicationRecord
  # Associations
  # belongs_to :user, optional: true

  # Validations
  validate :validate_url
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[https]) }
  validates :code, uniqueness: true, on: :update

  

  # Callbacks
  before_validation :normalize_url
  after_create :set_short_code

  private

  def normalize_url
    self.url = url&.strip
  end

  def validate_url
    return if url.blank?

    V1::ShortUrl::UrlValidator.new(short_url: self).call
  end

  def set_short_code
    update!(code: HASHIDS.encode(id))
  end
end
