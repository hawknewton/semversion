# frozen_string_literal: true

require 'json'

module Semversion
  class ProjectService
    PROJECT_TYPES = %w[npm gem naked].freeze

    def update_version(version)
      send(['update', project_type, 'version'].join('_'), version)
    end

    def version
      send([project_type, 'version'].join('_'))
    end

    private

    def update_naked_version(version)
      File.write('VERSION', version)
      %w[VERSION]
    end

    def update_gem_version(version)
      new_version_rb = version_rb.sub(
        /VERSION = "\d+\.\d+\.\d+"/, "VERSION = \"#{version}\""
      )

      raise "Could not update version in #{gem_version_file}" unless
        new_version_rb.include?(version)

      File.write(gem_version_file, new_version_rb)
      system('bundle install')
      [gem_version_file]
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

    def gem_version_file
      @gem_version_file ||= Dir.glob('lib/*/version.rb').first
    end

    def gem_version
      version_rb.match(/VERSION = "(\d+\.\d+\.\d+)"/)[1]
    end

    def npm_project?
      File.exist?('package.json')
    end

    def npm_version
      JSON.parse(File.read('package.json'))['version']
    end

    def gem_project?
      !gem_version_file.nil?
    end

    def naked_project?
      File.exist?('VERSION')
    end

    def naked_version
      File.read('VERSION').strip
    end

    def project_type
      PROJECT_TYPES.detect { |t| send([t, 'project?'].join('_')) } || unknown_project
    end

    def version_rb
      @version_rb ||= File.read(gem_version_file)
    end

    def unknown_project
      raise 'Cannot set version, unknown project format'
    end
  end
end
