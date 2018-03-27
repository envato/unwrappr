module Unwrappr
  class SpecVersionComparator
    # specs_versions is a hash like { name: 'version' }
    def self.perform(specs_versions_before, specs_versions_after)
      (specs_versions_before.keys + specs_versions_after.keys).uniq.sort.map do |key|
        {
          dependency: key,
          before: specs_versions_before[key],
          after: specs_versions_after[key],
        }
      end
    end
  end
end
