# frozen_string_literal: true

module Semversion
  class GitAdapter
    def commit(message, files)
      files.each { |f| `git add #{f}` }
      `git commit -m "#{message}"`
    end

    def create_note(note)
      `git notes add -m '#{note}'`
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

    def push
      `git push --follow-tags origin #{current_branch} 2> /dev/null`
    end

    def push_notes
      `git push origin 'refs/notes/*' 2> /dev/null`
    end

    def shallow_clone(url, ref)
      `git clone --depth 1 --branch #{ref} #{url} . 2> /dev/null`
      `git fetch origin 'refs/notes/*:refs/notes/*' 2> /dev/null`
    end

    def tags
      `git tag`.split("\n")
    end
  end
end
