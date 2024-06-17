# frozen_string_literal: true

RSpec.describe Semversion::GitService do
  around do |example|
    fixture_repo do
      example.run
    end
  end

  describe 'Getting the latest tag' do
    subject(:latest_tag) { described_class.new.latest_tag }

    context 'Given a repo with no tags' do
      it 'returns null' do
        expect(latest_tag).to be_nil
      end
    end

    context 'Given two semver tags' do
      it 'returns the latest one' do
        `git tag 0.1.0`
        `git commit --allow-empty -m 'another commit'`
        `git tag 1.0.0`

        expect(latest_tag).to eq('1.0.0')
      end
    end

    context 'Given two semver tags in the reverse order' do
      it 'returns the latest one' do
        `git tag 1.0.0`
        `git commit --allow-empty -m 'another commit'`
        `git tag 0.1.1`

        expect(latest_tag).to eq('1.0.0')
      end
    end

    context 'Given two semver tags and a non-semver tag' do
      it 'returns the latest one' do
        `git tag 1.0.0`
        `git tag asdfasfd`
        `git commit --allow-empty -m 'another commit'`
        `git tag 0.1.1`

        expect(latest_tag).to eq('1.0.0')
      end
    end
  end
end