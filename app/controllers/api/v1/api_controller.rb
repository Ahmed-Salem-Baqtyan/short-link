module Api::V1
  class ApiController < ApplicationController
    include ActionController::HttpAuthentication::Token::ControllerMethods
    include JsonResponders
    include ExceptionHandler
    include ActionParamsValidator
    include Authentication

    before_action :authenticate_request

    private

    def current_user
      Current.user
    end

    def authenticate_request
      unless request.headers['API-ACCESS-TOKEN'] == Rails.application.credentials.api_access_token
        head :unauthorized
      end
    end
  end
end
