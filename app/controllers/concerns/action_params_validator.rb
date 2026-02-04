# frozen_string_literal: true

module ActionParamsValidator
  extend ::ActiveSupport::Concern

  included do
    before_action :validate_params!
  end

  private

  def validate_params!
    self.send("validate_#{action_name}_params!")
  rescue RailsParam::InvalidParameterError => e
    raise(RailsParam::InvalidParameterError, e.message)
  rescue
    nil
  end
end
