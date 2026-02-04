# frozen_string_literal: true

module ExceptionHandler
  extend ::ActiveSupport::Concern

  included do
    rescue_from I18n::InvalidLocale,                with: :i18n_invalid_locale!
    rescue_from ActiveRecord::RecordNotFound,       with: :record_not_found
    rescue_from ActiveRecord::RecordInvalid,        with: :render_validation_error
    rescue_from ActionController::ParameterMissing, with: :parameter_missing
    rescue_from ::BadRequestError do |e|
      render_bad_request(message: e.message)
    end

    unless Rails.env.local?
      rescue_from StandardError, with: :server_error! do |err|
        server_error!(err)
      end
    end

    rescue_from ::ValidationFailed do |e|
      render_unprocessable_entity(message: e.message)
    end
  end

  private

  def record_not_found
    render_not_found
  end

  def server_error!(err)
    render_bad_request(message: 'Internal Server Error')
  end

  def i18n_invalid_locale!
    render_error(message: I18n.t('errors.invalid_language'))
  end

  def not_authorized!
    render_forbidden(message: I18n.t('errors.e_403'))
  end

  def parameter_missing(exception)
    render_bad_request(message: exception.message)
  end

  def render_validation_error(exception)
    render_unprocessable_entity(message: exception.message)
  end
end