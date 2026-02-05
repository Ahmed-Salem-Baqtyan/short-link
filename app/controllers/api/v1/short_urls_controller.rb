module Api::V1
  class ShortUrlsController < ApiController

    before_action :validate_encode_params!, only: [ :encode ]
    allow_unauthenticated_access only: [:decode]

    # POST /api/v1/short_urls/encode
    def encode
      short_url = current_user.short_urls.create!(encode_params)
      encoded_url = "#{request.base_url}/api/v1/short_urls/decode/#{short_url.code}"
      data = { encoded_url: encoded_url }

      render_success(message: "Link encoded successfully", data:)
    end

    # GET /api/v1/short_urls/decode/:code
    def decode
      short_url = ShortUrl.find_by(code: params[:code])

      if short_url
        data = { decoded_url: short_url.url }
        render_success(message: "Link decoded successfully", data:)
      else
        render_not_found(message: "This is a 404 error, which means you've entered an invalid URL")
      end
    end

    private

    def encode_params
      params.require(:short_url).permit(:url)
    end

    def validate_encode_params!
      param!(:short_url, Hash, required: true, blank: false) do |h|
        h.param!(:url, String, required: true, blank: false)
      end
    end
  end
end
