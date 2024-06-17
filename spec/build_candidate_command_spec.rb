# frozen_string_literal: true

RSpec.describe Semversion::BuildCandidateCommand do
  let(:mock_git_adapter) { instance_double('Semversion::GitAdapter') }
  let(:mock_project_service) { instance_double('Semversion::ProjectService') }

  describe '#exec' do
    subject(:exec) { described_class.new(git_adapter: mock_git_adapter, project_service: mock_project_service).exec }

    context 'when the current branch is main' do
      before do
        allow(mock_git_adapter).to receive(:current_branch).and_return 'main'
        allow(mock_git_adapter).to receive(:create_tag)
        allow(mock_git_adapter).to receive(:commit)
        allow(mock_git_adapter).to receive(:push)
        allow(mock_project_service).to receive(:update_version).and_return(%w[project files])
        allow(mock_project_service).to receive(:version).and_return '1.2.3'
      end

      context 'and the last relase went to production' do
        before do
          allow(mock_git_adapter)
            .to receive(:notes)
            .with('1.2.3')
            .and_return(['version 1.2.3 deployed to production at 2021-08-01 12:00:00'])
        end

        it 'bumps the minor' do
          exec

          expect(mock_project_service).to have_received(:update_version).with('1.3.0')
        end

        it 'commits the version changes' do
          exec

          expect(mock_git_adapter).to have_received(:commit).with('Bump version to 1.3.0', %w[project files])
        end

        it 'pushes the changes' do
          exec

          expect(mock_git_adapter).to have_received(:push)
        end

        it 'tags the release' do
          exec

          expect(mock_git_adapter).to have_received(:create_tag).with('1.3.0', 'Version 1.3.0 tagged by Semversion')
        end

        it 'calls the git adapter in the right order' do
          exec

          expect(mock_git_adapter).to have_received(:commit).ordered
          expect(mock_git_adapter).to have_received(:create_tag).ordered
          expect(mock_git_adapter).to have_received(:push).ordered
        end
      end

      context 'and the last release did not go to production' do
        before do
          allow(mock_git_adapter).to receive(:notes).with('1.2.3').and_return []
        end
        it 'bumps the patch' do
          exec

          expect(mock_project_service).to have_received(:update_version).with('1.2.4')
        end
      end
    end

    context 'when the current branch is a hotfix branch and the last release went to production' do
      before do
        allow(mock_git_adapter)
          .to receive(:notes)
          .with('1.2.3')
          .and_return(['version 1.2.3 deployed to production at 2021-08-01 12:00:00'])
        allow(mock_git_adapter).to receive(:current_branch).and_return 'hotfix-1.2'
        allow(mock_git_adapter).to receive(:create_tag)
        allow(mock_git_adapter).to receive(:commit)
        allow(mock_git_adapter).to receive(:push)
        allow(mock_project_service).to receive(:update_version).and_return(%w[project files])
        allow(mock_project_service).to receive(:version).and_return '1.2.3'
      end

      it 'bumps the patch for the given minor' do
        exec

        expect(mock_project_service).to have_received(:update_version).with('1.2.4')
      end
    end

    context 'when the current branch is none neither main nor hotfix' do
      before do
        allow(mock_project_service).to receive(:version).and_return '1.2.3'
        allow(mock_git_adapter).to receive(:current_branch).and_return 'not-a-real-branch'
      end

      it 'raises an error' do
        expect { exec }.to raise_error('Branch not hotfix, master, or main!')
      end
    end
  end
end
