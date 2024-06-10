# frozen_string_literal: true

module Semversion
  class GitService
    def latest_tag
      GitAdapter.new.tags.select { |tag| Semver.semver?(tag) }
                .max { |a, b| Semver.new(a).sort(Semver.new(b)) }
    end
  end
end
