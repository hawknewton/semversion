# frozen_string_literal: true

require 'tty-command'

module Semversion
  class GitAdapter
    def commit(message, files)
      files.each { |f| `git add #{f}` }
      run("git commit -m '#{message}'")
    end

    def create_note(note)
      run("git notes append -m '#{note}'")
    end

    def current_branch
      run('git rev-parse --abbrev-ref HEAD').strip
    end

    def create_tag(tag, message)
      run("git tag -a #{tag} -m '#{message}'")
    end

    def debug?
      ENV.fetch('DEBUG', 'false') == 'true'
    end

    def notes(tag)
      return [] unless tags.include?(tag)

      ref = run("git rev-list -n 1 #{tag}").strip
      run("git notes show #{ref}").split("\n").reject(&:empty?)
    rescue TTY::Command::ExitError => e
      return [] if e.message.include?('no note found')

      raise
    end

    def push
      run("git push --follow-tags origin #{current_branch}")
    end

    def pull_notes
      run("git fetch origin 'refs/notes/*:refs/notes/*'")
    end

    def push_notes
      run("git push origin 'refs/notes/*'")
    end

    def shallow_clone(url, ref)
      run("git clone --depth 1 --branch #{ref} #{url} .")
      run("git fetch origin 'refs/notes/*:refs/notes/*'")
    end

    def tags
      run('git tag').split("\n")
    end

    def run(command)
      cmd = TTY::Command.new(printer: debug? ? :pretty : :null)
      cmd.run(command).to_a.join("\n")
    end
  end
end
