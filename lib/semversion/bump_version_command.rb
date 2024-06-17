# frozen_string_literal: true

module Semversion
  class BumpVersionCommand
    def initialize(git_adapter:, project_service:)
      @git_adapter = git_adapter
      @project_service = project_service
    end

    def exec
      files = @project_service.update_version(next_version)
      @git_adapter.commit("Bump version to #{next_version}", files)
      @git_adapter.create_tag(next_version, "Version #{next_version} tagged by Semversion")
      @git_adapter.push
    end

    private

    def hotfix_branch?
      raise 'Branch not hotfix, master, or main!' unless
        @git_adapter.current_branch =~ /^(hotfix-[0-9]+\.[0-9]+|master|main)$/

      @git_adapter.current_branch.start_with?('hotfix-')
    end

    def last_version_deployed_to_production?
      notes = @git_adapter.notes(version)
      return false unless notes.any?

      notes.any? { |note| note.start_with?("version #{version} deployed to production") }
    end

    def next_version
      semver = Semver.new(version)
      semver.public_send(!hotfix_branch? && last_version_deployed_to_production? ? :bump_minor : :bump_patch)
      semver.to_s
    end

    def version
      @version ||= @project_service.version
    end
  end
end
