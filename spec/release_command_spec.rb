# frozen_string_literal: true

RSpec.describe Semversion::ReleaseCommand do
  let(:mock_git_adapter) { instance_double('Semversion::GitAdapter') }

  describe '#exec' do
    subject(:exec) do
      described_class.new(
        origin: 'origin',
        version: '1.2.3',
        git_adapter: mock_git_adapter
      ).exec
    end

    before do
      allow(mock_git_adapter).to receive(:shallow_clone)
      allow(mock_git_adapter).to receive(:create_note)
      allow(mock_git_adapter).to receive(:push_notes)
      allow(mock_git_adapter).to receive(:notes).and_return([])
    end

    it 'clones the repo in a temp directory' do
      this_dir = Dir.pwd

      expect(mock_git_adapter).to receive(:shallow_clone).with('origin', '1.2.3') do
        expect(Dir.pwd).to_not eq this_dir
      end

      exec
    end

    context 'when no note exists' do
      it 'creates the note' do
        exec

        expect(mock_git_adapter).to have_received(:create_note).with(/^version 1.2.3 deployed to production at .+$/)
      end
    end

    context 'when a note exists' do
      context do
        before do
          allow(mock_git_adapter).to receive(:notes)
            .with('1.2.3')
            .and_return(['version 1.2.3 deployed to production at 2021-08-01 12:00:00'])
        end

        it 'appends the note' do
          exec

          expect(mock_git_adapter).to have_received(:create_note) do |arg|
            notes = arg.split("\n")
            expect(notes.length).to eq 2
            expect(notes)
              .to match_array(
                [
                  'version 1.2.3 deployed to production at 2021-08-01 12:00:00',
                  /version 1.2.3 deployed to production at/
                ]
              )
          end
        end
      end
    end

    it 'pushes notes repo upstream' do
      exec

      expect(mock_git_adapter).to have_received(:push_notes)
    end
  end
end
