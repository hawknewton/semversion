require 'json'

RSpec.describe Semversion::ProjectService do
  around do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        example.run
      end
    end
  end

  describe 'Bumping project version' do
    subject(:update_version) do
      instance.update_version('2.0.0')
    end

    let(:instance) { described_class.new }

    context 'Given a npm project' do
      before do
        project = { name: 'test-project', version: '1.0.0' }
        File.write('project.json', JSON.dump(project))
        File.write('project-lock.json', JSON.dump(project))
      end

      it 'updates the version in package.json' do
        update_version
        result = JSON.parse(File.read('project.json'), symbolize_names: true)
        expect(result).to include(
          name: 'test-project',
          version: '2.0.0'
        )
      end

      it 'updates the version in package-lock.json' do
        update_version
        result = JSON.parse(File.read('project-lock.json'), symbolize_names: true)
        expect(result).to include(
          name: 'test-project',
          version: '2.0.0'
        )
      end
    end

    context 'Given a ruby gem project' do
      before do
        Dir.mkdir('lib')
        Dir.mkdir('lib/project')

        File.write('lib/project/version.rb', "module Project\n  VERSION = \"1.0.0\"\nend")

        allow(instance).to receive(:system).and_return nil
      end

      it 'updates the version in lib/*/version.rb' do
        update_version
        version_content = File.read('lib/project/version.rb')

        # Extract the current version number
        current_version = version_content.match(/VERSION = "(\d+\.\d+\.\d+)"/)[1]
        expect(current_version).to eq '2.0.0'
      end

      it 'runs bundler' do
        update_version
        expect(instance).to have_received(:system).with('bundle install')
      end
    end

    context 'Given a ruby app' do
      before do
        File.write('VERSION', '1.0.0')
      end

      it 'updates the version in VERSION' do
        update_version

        expect(File.read('VERSION').strip).to eq '2.0.0'
      end
    end

    context 'Given no recognizable files' do
      it 'raises an error' do
        expect { update_version }.to raise_error(/unknown project format/)
      end
    end
  end
end
