# frozen_string_literal: true

module Semversion
  class ReleaseCommand
    def initialize(origin:, version:, git_adapter: GitAdapter.new)
      @origin = origin
      @version = version
      @git_adapter = git_adapter
    end

    def exec
      in_temp_dir do
        @git_adapter.shallow_clone(@origin, @version)
        @git_adapter.create_note(notes)
        @git_adapter.push_notes
      end

      Logger.info("Version #{@version} released")
    end

    private

    def in_temp_dir(&block)
      Dir.chdir(Dir.mktmpdir) do
        block.call
      end
    end

    def notes
      (@git_adapter.notes(@version) +
        ["version #{@version} deployed to production at #{now}"]).join("\n")
    end

    def now
      Time.now.strftime('%Y-%m-%d %H:%M:%S')
    end
  end
end
