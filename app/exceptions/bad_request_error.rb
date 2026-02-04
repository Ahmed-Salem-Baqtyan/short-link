# frozen_string_literal: true

class BadRequestError < StandardError
  def initialize(message = I18n.t('errors.e_400'))
    super(message)
  end
end