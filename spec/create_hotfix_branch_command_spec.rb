RSpec.describe Semversion::CreateHotfixBranchCommand do
  let(:mock_git_adapter) { instance_double('Semversion::GitAdapter') }

  describe '#exec' do
    subject(:exec) do
      described_class.new(git_adapter: mock_git_adapter, major_minor: major_minor).exec
    end
    let(:major_minor) { '1.2' }

    context 'when the current branch is main' do
      before do
        allow(mock_git_adapter).to receive(:tags).and_return(['1.2.0', '1.2.1'])
        allow(mock_git_adapter).to receive(:create_branch)
        allow(mock_git_adapter).to receive(:push)
      end

      it 'creates the branch' do
        exec

        expect(mock_git_adapter).to have_received(:create_branch).with('hotfix-1.2', '1.2.1')
      end

      it 'pushes the branch' do
        exec

        expect(mock_git_adapter).to have_received(:push)
      end
    end

    context 'when the major.minor is not numeric' do
      let(:major_minor) { '1.a' }
      it 'raises an error' do
        expect { exec }.to raise_error(/major.minor must be numeric/)
      end
    end
  end
end
