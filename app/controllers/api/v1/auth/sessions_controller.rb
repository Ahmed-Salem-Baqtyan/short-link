module Api::V1::Auth
  class SessionsController < Api::V1::ApiController
    allow_unauthenticated_access only: [ :create ]

    # POST /api/v1/auth/sessions
    def create
      if user = User.authenticate_by(session_params)
        start_new_session_for(user)
        render json: { token: Current.session.token }
      else
        render json: { error: "Invalid email address or password" }, status: :unauthorized
      end
    end

    private

    def session_params
      params.permit(:email_address, :password)
    end

    def validate_create_params!
      param!(:email_address, String, required: true, blank: false)
      param!(:password, String, required: true, blank: false)
    end
  end
end
