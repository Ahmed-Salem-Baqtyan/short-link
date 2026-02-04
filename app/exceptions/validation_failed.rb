# frozen_string_literal: true

class ValidationFailed < StandardError
  attr_accessor :options

  def initialize(message, options = {})
    self.options = options
    super(message)
  end
end
