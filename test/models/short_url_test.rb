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

require "test_helper"

class ShortUrlTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
