module Semversion
  class ProjectService
    def update_version(version)
      return update_npm_version(version) if File.exist?('project.json')

      return update_gem_version(version) if ruby_gem_version_file

      return update_app_version(version) if File.exist?('VERSION')

      raise 'Cannot set version, unknown project format'
    end

    private

    def update_app_version(version)
      File.write('VERSION', version)
    end

    def update_gem_version(version)
      version_content = File.read(ruby_gem_version_file)
      new_version_content = version_content.sub(
        /VERSION = "\d+\.\d+\.\d+"/, "VERSION = \"#{version}\""
      )

      raise "Could not update version in #{ruby_gem_version_file}" unless
        new_version_content.include?(version)

      File.write(ruby_gem_version_file, new_version_content)
      system('bundle install')
    end

    def update_npm_version(version)
      ['project.json', 'project-lock.json'].each do |file|
        update_project_file(file, version)
      end
    end

    def update_project_file(file_name, version)
      project = JSON.parse(File.read(file_name))
      project['version'] = version
      File.write(file_name, JSON.pretty_generate(project))
    end

    def ruby_gem_version_file
      @ruby_gem_version_file ||= Dir.glob('lib/*/version.rb').first
    end
  end
end
