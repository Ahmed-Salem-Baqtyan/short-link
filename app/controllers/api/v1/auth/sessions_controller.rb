module Api::V1::Auth
  class SessionsController < Api::V1::ApiController
    allow_unauthenticated_access only: [ :create ]

    # POST /api/v1/auth/sessions
    def create
      if user = User.authenticate_by(session_params)
        start_new_session_for(user)

        data = {
          token: Current.session.token,
          user: Current.user.slice(:id, :email_address)
        }

        render_success(message: "Logged in successfully", data:)
      else
        render_unauthorized(message: "Invalid email address or password")
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
