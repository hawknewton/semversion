# frozen_string_literal: true

RSpec.describe Semversion::Semver do
  describe '::semver?' do
    subject { Semversion::Semver.semver?(tag) }

    context 'Given a string that is a semver tag' do
      let(:tag) { '1.2.3' }

      it { is_expected.to be true }
    end

    context 'Given nil' do
      let(:tag) { nil }

      it { is_expected.to be false }
    end

    context 'Given 1.2.c' do
      let(:tag) { '1.2.c' }

      it { is_expected.to be false }
    end

    context 'Given asdfasdf' do
      let(:tag) { 'asdfasdf' }

      it { is_expected.to be false }
    end
  end
  describe '#sort' do
    subject { Semversion::Semver.new(version).sort(other_semver) }
    let(:version) { '2.2.2' }

    context 'Given anothr tag that has a higher major' do
      let(:other_semver) { Semversion::Semver.new('3.2.2') }
      it { is_expected.to eq(-1) }
    end

    context 'Given anothr tag that has a lower major' do
      let(:other_semver) { Semversion::Semver.new('1.2.2') }

      it { is_expected.to eq 1 }
    end

    context 'Given another semver with the same major' do
      let(:other_semver) { Semversion::Semver.new('2.1.2') }
      context 'and a lower minor' do
        it { is_expected.to eq 1 }
      end

      context 'and a higher minor' do
        let(:other_semver) { Semversion::Semver.new('2.3.2') }
        it { is_expected.to eq(-1) }
      end

      context 'the same lower minor' do
        context 'and a lower patch' do
          let(:other_semver) { Semversion::Semver.new('2.2.1') }

          it { is_expected.to eq 1 }
        end

        context 'and a higher patch' do
          let(:other_semver) { Semversion::Semver.new('2.2.3') }

          it { is_expected.to eq(-1) }
        end

        context 'and a the same patch' do
          let(:other_semver) { Semversion::Semver.new('2.2.2') }
          it { is_expected.to eq 0 }
        end
      end
    end
  end
end
