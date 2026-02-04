module Api::V1
  class ApiController < ApplicationController
    include JsonResponders
    include ExceptionHandler

    before_action :authenticate_request

    private

    def authenticate_request
      unless request.headers['API-ACCESS-TOKEN'] == Rails.application.credentials.api_access_token
        head :unauthorized
      end
    end
  end
end
