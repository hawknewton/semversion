# frozen_string_literal: true

require 'json'

module Semversion
  class ProjectService
    def update_version(version)
      return update_npm_version(version) if npm_project?

      return update_gem_version(version) if ruby_gem_project?

      return update_app_version(version) if naked_version_project?

      unknown_project
    end

    def version
      return JSON.parse(File.read('package.json'))['version'] if npm_project?

      return version_rb.match(/VERSION = "(\d+\.\d+\.\d+)"/)[1] if ruby_gem_project?

      return File.read('VERSION').strip if naked_version_project?

      unknown_project
    end

    private

    def update_app_version(version)
      File.write('VERSION', version)
      %w[VERSION]
    end

    def update_gem_version(version)
      new_version_rb = version_rb.sub(
        /VERSION = "\d+\.\d+\.\d+"/, "VERSION = \"#{version}\""
      )

      raise "Could not update version in #{ruby_gem_version_file}" unless
        new_version_rb.include?(version)

      File.write(ruby_gem_version_file, new_version_rb)
      system('bundle install')
      [ruby_gem_version_file]
    end

    def update_npm_version(version)
      files = ['package.json', 'package-lock.json']
      files.each do |file|
        update_npm_project_file(file, version)
      end
      files
    end

    def update_npm_project_file(file_name, version)
      project = JSON.parse(File.read(file_name))
      project['version'] = version
      File.write(file_name, JSON.pretty_generate(project))
    end

    def ruby_gem_version_file
      @ruby_gem_version_file ||= Dir.glob('lib/*/version.rb').first
    end

    def npm_project?
      File.exist?('package.json')
    end

    def ruby_gem_project?
      !ruby_gem_version_file.nil?
    end

    def naked_version_project?
      File.exist?('VERSION')
    end

    def version_rb
      @version_rb ||= File.read(ruby_gem_version_file)
    end

    def unknown_project
      raise 'Cannot set version, unknown project format'
    end
  end
end
