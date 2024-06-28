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

  describe 'Getting the latest patch for a given major.minor' do
    subject(:latest_patch) { described_class.new.latest_patch(major_minor) }
    let(:major_minor) { '1.2' }

    context 'when no tags exist' do
      it 'raises an error' do
        expect { latest_patch }.to raise_error(Semversion::NoVersionError)
      end
    end

    context 'when tags exist but don\'t match the major.minor' do
      before do
        `git tag 1.0.0`
        `git tag 1.0.1`
      end

      it 'raises an error' do
        expect { latest_patch }.to raise_error(Semversion::NoVersionError)
      end
    end

    context 'given tags 1.2.0 and 1.2.1' do
      before do
        `git tag 1.2.0`
        `git tag 1.2.1`
      end

      it { is_expected.to eq('1.2.1') }
    end

    context 'given tags 1.2.1 and 1.2.0' do
      before do
        `git tag 1.2.1`
        `git tag 1.2.0`
      end

      it { is_expected.to eq('1.2.1') }
    end
  end
end
