module Unwrappr
  class SpecVersionComparator
    # specs are arrays of specs like 'name (version)'
    def self.perform(specs_before, specs_after)
      index_before = build_spec_index(specs_before)
      index_after = build_spec_index(specs_after)

      (index_before.keys + index_after.keys).uniq.sort.map do |key|
        {
          dependency: key,
          before: index_before[key],
          after: index_after[key],
        }
      end
    end

    def self.build_spec_index(specs)
      Hash[specs.map { |item| parse_spec(item) }]
    end

    def self.parse_spec(spec)
      md = spec.match /^([^\s]+)\s\(([^\s]+)\)$/
      raise ArgumentError, spec if md.nil?
      [md[1], md[2]]
    end

    private_class_method :build_spec_index, :parse_spec
  end
end
