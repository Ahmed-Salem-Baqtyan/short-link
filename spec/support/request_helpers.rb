# frozen_string_literal: true

module Requests
  module JsonHelpers
    def json_response
      JSON.parse(response.body, symbolize_names: true).with_indifferent_access
    end

    def data_response
      json_response[:data]
    end

    def error_response
      json_response[:message]
    end

    def success_response
      json_response[:success]
    end

    def message_response
      json_response[:message]
    end
  end
end
