# frozen_string_literal: true

require 'json'

module Unwrappr
  # A wrapper around RubyGems' API
  module RubyGems
    SERVER = 'https://rubygems.org'
    GET_GEM = '/api/v1/gems/%s.json'

    class << self
      def gem_info(name)
        parse(Faraday.get(SERVER + GET_GEM % name), name)
      end

      def try_get_source_code_uri(gem_name)
        Unwrappr::RubyGems.gem_info(gem_name)&.source_code_uri
      end

      private

      def parse(response, name)
        case response.status
        when 200
          JSON.parse(response.body, object_class: OpenStruct)
        when 404
          nil
        else
          STDERR.puts(error_message(response: response, name: name))
        end
      end

      def error_message(response:, name:)
        "Rubygems response for #{name}: "\
        "HTTP #{response.status}: #{response.body}"
      end
    end
  end
end
