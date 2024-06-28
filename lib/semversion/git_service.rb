# frozen_string_literal: true

module Semversion
  class GitService

    def initialize(git_adapter: GitAdapter.new)
      @git_adapter = git_adapter
    end

    def latest_tag
      max(semvers)
    end

    def latest_patch(major_minor)
      max(semvers.select { |t| t.to_s.start_with?("#{major_minor}.") }) || raise(NoVersionError)
    end

    private

    def max(tags)
      tags.max { |a, b| Semver.new(a).sort(Semver.new(b)) }
    end

    def semvers
      @semvers ||= @git_adapter.tags.select { |tag| Semver.semver?(tag) }
    end
  end
end
