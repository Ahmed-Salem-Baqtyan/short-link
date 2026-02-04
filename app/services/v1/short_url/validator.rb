module V1::ShortUrl
  class Validator
    def initialize(short_url:)
      @short_url = short_url
    end

    def call
    end

    private

    attr_reader :short_url
  end
end