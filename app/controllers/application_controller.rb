class ApplicationController < ActionController::API
  def server_status
    render(
      json: {
        success: true,
        message: "API Server is up",
        env: Rails.env
      }
    )
  end
end
