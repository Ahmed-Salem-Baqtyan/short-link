module Api::V1
  class ShortUrlsController < ApiController
    # POST /api/v1/short_urls/encode
    def encode
      # Create the url for the user
      short_url = ShortUrl.create!(encode_params)
      encoded_url = "#{request.base_url}/api/v1/short_urls/decode/#{short_url.code}"
      data = { encoded_url: encoded_url }

      render_success(message: "Link encoded successfully", data:)
    end

    # GET /api/v1/short_urls/decode/:short_code
    def decode
      validate_decode_params!

      # Find the url for the user
      short_url = ShortUrl.find_by!(code: short_code)
      data = { decoded_url: short_url.original_url }

      render_success(message: "Link decoded successfully", data:)
    end

    private

    def encode_params
      params.require(:short_url).permit(:url)
    end

    def validate_decode_params!
      code = params[:code]

      raise(BadRequestError, "Code is required") if code.blank?
      raise(BadRequestError, "Code is too long (max 6 characters)") if code.length > 6
      raise(BadRequestError, "Invalid code format") unless code.match?(/\A[a-zA-Z0-9]+\z/)
    end
  end
end
