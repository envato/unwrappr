# frozen_string_literal: true

module Unwrappr
  # Facilitates interactions with environment variables.
  module Environment
    def self.with_environment_variable(name, value)
      original_value = ENV[name]
      ENV[name] = value
      yield
    ensure
      ENV[name] = original_value
    end
  end
end
