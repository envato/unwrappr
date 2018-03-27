module Unwrappr
  class SpecVersionComparator
    # specs_versions is a hash like { name: 'version' }
    def self.perform(specs_versions_before, specs_versions_after)
      keys = (specs_versions_before.keys + specs_versions_after.keys).uniq
      changes = keys.sort.map do |key|
        {
          dependency: key,
          before: specs_versions_before[key],
          after: specs_versions_after[key],
        }
      end

      changes.reject { |rec| rec[:before] == rec[:after] }
    end
  end
end
