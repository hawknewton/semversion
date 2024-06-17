# frozen_string_literal: true

RSpec.describe Semversion::GitAdapter do
  context 'Given an example repo' do
    around do |example|
      fixture_repo do
        example.run
      end
    end

    describe 'Getting tags' do
      subject { Semversion::GitAdapter.new.tags }

      context 'Given a repo with tags' do
        it 'returns the tags' do
          `git tag 0.1.0`
          `git commit --allow-empty -m 'another commit'`
          `git tag 1.0.0`

          expect(subject).to match_array(%w[0.1.0 1.0.0])
        end
      end
    end

    describe 'Getting notes' do
      subject { Semversion::GitAdapter.new.notes(tag) }

      context 'Given a tag that does not exist' do
        let(:tag) { 'this-is-not-a-tag' }

        it { is_expected.to be_empty }
      end

      context 'Given no notes for the tag' do
        let(:tag) { '1.0.0' }

        before do
          `git tag 1.0.0`
        end

        it { is_expected.to be_empty }
      end

      context 'Give a note for the tag' do
        let(:tag) { '1.0.0' }

        before do
          `git tag 1.0.0`
          `git notes add -m 'Test note'`
        end

        it 'returns the note' do
          expect(subject).to match_array ['Test note']
        end
      end
    end

    describe 'Getting the current branch' do
      subject { described_class.new.current_branch }

      before do
        `git checkout -b test-branch 2> /dev/null`
      end

      it 'returns the current branch' do
        expect(subject).to eq 'test-branch'
      end
    end

    describe 'Creating a tag' do
      subject! { described_class.new.create_tag('123', 'message') }

      it 'creates a tag based on HEAD' do
        tags = `git tag`.strip.split("\n")
        expect(tags).to match_array ['123']
      end

      it 'annotates the tag with the given message' do
        message = `git for-each-ref refs/tags/123 --format='%(contents)'`.strip
        expect(message).to eq message
      end
    end

    describe 'Committing a change' do
      subject(:commit) { described_class.new.commit('commit message', %w[file1 file2]) }

      before do
        File.write('file1', 'test 1')
        File.write('file2', 'test 2')
        File.write('file3', 'test 3')
      end

      it 'commits the change' do
        commit

        files = `git diff-tree --no-commit-id --name-only -r HEAD`.strip.split("\n")
        expect(files).to match_array %w[file1 file2]
      end
    end

    describe 'Creating a note' do
      subject(:create_note) { described_class.new.create_note('this is a test note') }
      it 'creates a note' do
        create_note

        note = `git notes show`.strip

        expect(note).to eq 'this is a test note'
      end
    end
  end

  context 'Given an upstream repo' do
    around do |example|
      Dir.chdir(Dir.mktmpdir) do
        example.run
      end
    end

    let(:origin) do
      fixture_repo do
        `git notes add -m 'this is the first test note'`
        File.write('test_file', 'this is a test file')
        `git add test_file`
        `git commit -m 'second commit'`
        `git tag -a 1.2.3 -m 'release 1.2.3'`
        `git rm test_file`
        `git commit -m 'removing test file'`
        `git notes add -m 'this is the second test note'`
      end
    end

    describe 'performing a shallow clone' do
      subject(:shallow_clone) { described_class.new.shallow_clone(['file://', origin].join, '1.2.3') }

      it 'clones the repo contents' do
        shallow_clone
        test_file = File.read('test_file')

        expect(test_file).to eq 'this is a test file'
      end

      it 'gets just one commit' do
        shallow_clone

        expect(`git rev-list head --count`.strip).to eq '1'
      end

      it 'clones the notes' do
        shallow_clone

        notes = `git notes list`
        expect(notes.strip.split("\n").size).to eq 2
      end
    end

    describe 'Pushing to origin' do
      subject(:push) { described_class.new.push }

      before do
        Dir.chdir(origin) { `git config --local receive.denyCurrentBranch ignore` }

        `git clone #{origin} . 2> /dev/null`
        `git fetch origin 'refs/notes/*:refs/notes/*' 2> /dev/null`
      end

      it 'pushes to origin' do
        `git commit --allow-empty -m 'testing push'`
        push

        Dir.chdir(origin) do
          commits = `git rev-list head --count`.strip
          expect(commits).to eq '4'
        end
      end

      it 'pushes tags' do
        `git commit --allow-empty -m 'testing push'`
        `git tag -a 2.0.0 -m 'release 2.0.0'`
        push

        Dir.chdir(origin) do
          commits = `git rev-list 2.0.0 --count`.strip
          expect(commits).to eq '4'
        end
      end
    end

    describe 'Pushing notes' do
      subject(:push_notes) { described_class.new.push_notes }

      before do
        Dir.chdir(origin) { `git config --local receive.denyCurrentBranch ignore` }

        `git clone #{origin} . 2> /dev/null`
        `git fetch origin 'refs/notes/*:refs/notes/*' 2> /dev/null`
      end

      it 'pushes the notes' do
        `git commit --allow-empty -m 'testing push'`
        `git notes add -m 'this is a test note'`
        push_notes

        Dir.chdir(origin) do
          notes = `git notes list`.strip.split("\n").size
          expect(notes).to eq 3
        end
      end
    end
  end
end
