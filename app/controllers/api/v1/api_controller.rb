module Api::V1
  class ApiController < ApplicationController
    before_action :authenticate_request

    include ActionController::HttpAuthentication::Token::ControllerMethods
    include Authentication
    include JsonResponders
    include ExceptionHandler
    include ActionParamsValidator

    private

    def current_user
      Current.user
    end

    def authenticate_request
      unless request.headers["API-ACCESS-TOKEN"] == Rails.application.credentials.api_access_token
        render_unauthorized(message: "You dont have access to this resource")
      end
    end
  end
end
