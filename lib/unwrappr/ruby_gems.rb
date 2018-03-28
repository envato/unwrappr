require 'json'

module Unwrappr
  module RubyGems
    SERVER = 'https://rubygems.org'.freeze
    GET_GEM = '/api/v1/gems/%s.json'.freeze

    class << self
      def gem_info(name)
        parse(Faraday.get(SERVER + GET_GEM % name), name)
      end

      private

      def parse(response, name)
        case response.status
        when 200
          JSON.parse(response.body, object_class: OpenStruct)
        when 404
          nil
        else
          STDERR.puts("Rubygems response for #{name}: HTTP #{response.status}: #{response.body}")
        end
      end
    end
  end
end