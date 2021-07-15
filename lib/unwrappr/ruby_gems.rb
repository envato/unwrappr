# frozen_string_literal: true

require 'json'

module Unwrappr
  # A wrapper around RubyGems' API
  module RubyGems
    SERVER = 'https://rubygems.org'
    GET_GEM = '/api/v2/rubygems/%s/versions/%s.json'

    class << self
      def gem_info(name, version)
        parse(Faraday.get(SERVER + format(GET_GEM, name, version)), name)
      end

      private

      def parse(response, name)
        case response.status
        when 200
          JSON.parse(response.body, object_class: OpenStruct)
        when 404
          nil
        else
          warn(error_message(response: response, name: name))
        end
      end

      def error_message(response:, name:)
        "Rubygems response for #{name}: "\
          "HTTP #{response.status}: #{response.body}"
      end
    end
  end
end
