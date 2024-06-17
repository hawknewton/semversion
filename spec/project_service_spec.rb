# frozen_string_literal: true

require 'json'

RSpec.describe Semversion::ProjectService do
  around do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        example.run
      end
    end
  end

  describe 'Getting the current version' do
    subject(:version) { described_class.new.version }

    context 'Given a npm project' do
      before do
        package = { name: 'test-project', version: '1.0.0' }
        File.write('package.json', JSON.dump(package))
        File.write('package-lock.json', JSON.dump(package))
      end

      it 'gets the project version' do
        expect(version).to eq '1.0.0'
      end
    end

    context 'Given a ruby gem project' do
      before do
        Dir.mkdir('lib')
        Dir.mkdir('lib/project')

        File.write('lib/project/version.rb', "module Project\n  VERSION = \"1.0.0\"\nend")
      end

      it 'gets the project version' do
        expect(version).to eq '1.0.0'
      end
    end

    context 'Given a ruby app' do
      before do
        File.write('VERSION', '1.0.0')
      end
      it 'gets the project version' do
        expect(version).to eq '1.0.0'
      end
    end

    context 'Given no recognizable files' do
      it 'raises an error' do
        expect { version }.to raise_error(/unknown project format/)
      end
    end
  end

  describe 'Updating project version' do
    subject(:update_version) do
      instance.update_version('2.0.0')
    end

    let(:instance) { described_class.new }

    context 'Given a npm project' do
      before do
        project = { name: 'test-project', version: '1.0.0' }
        File.write('package.json', JSON.dump(project))
        File.write('package-lock.json', JSON.dump(project))
      end

      it 'updates the version in package.json' do
        update_version
        result = JSON.parse(File.read('package.json'), symbolize_names: true)
        expect(result).to include(
          name: 'test-project',
          version: '2.0.0'
        )
      end

      it 'updates the version in package-lock.json' do
        update_version
        result = JSON.parse(File.read('package-lock.json'), symbolize_names: true)
        expect(result).to include(
          name: 'test-project',
          version: '2.0.0'
        )
      end

      it { is_expected.to match_array(%w[package.json package-lock.json]) }
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

      it { is_expected.to match_array(%w[lib/project/version.rb]) }
    end

    context 'Given a ruby app' do
      before do
        File.write('VERSION', '1.0.0')
      end

      it 'updates the version in VERSION' do
        update_version

        expect(File.read('VERSION').strip).to eq '2.0.0'
      end

      it { is_expected.to match_array(%w[VERSION]) }
    end

    context 'Given no recognizable files' do
      it 'raises an error' do
        expect { update_version }.to raise_error(/unknown project format/)
      end
    end
  end
end
