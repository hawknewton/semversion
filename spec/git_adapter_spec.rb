# frozen_string_literal: true

RSpec.describe Semversion::GitAdapter do
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
end
