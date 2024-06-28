module Semversion
  class CreateHotfixBranchCommand
    def initialize(git_adapter: GitAdapter.new, major_minor:)
      @git_adapter = git_adapter
      @major_minor = major_minor
    end

    def exec
      raise 'major.minor must be numeric' if @major_minor !~ /^\d+\.\d+$/ 

      @git_adapter.create_branch(branch, latest_patch)
      @git_adapter.push

      Logger.info("Created branch #{branch} from #{latest_patch}")
    end

    private

    def branch
      @branch ||= ['hotfix', @major_minor].join('-')
    end

    def latest_patch
      @latest_patch ||= GitService.new(git_adapter: @git_adapter).latest_patch(@major_minor)
    end
  end
end
