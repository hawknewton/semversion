module Semversion
  class GitAdapter
    def commit(message, files)
      files.each { |f| `git add #{f}` }
      `git commit -m "#{message}"`
    end

    def current_branch
      `git rev-parse --abbrev-ref HEAD`.strip
    end

    def create_tag(tag, message)
      `git tag -a #{tag} -m '#{message}'`
    end

    def notes(tag)
      return [] if !tags.include?(tag) || `git notes list #{tag} 2>/dev/null`.empty?

      `git notes show #{tag}`.split("\n")
    end

    def tags
      `git tag`.split("\n")
    end
  end
end
