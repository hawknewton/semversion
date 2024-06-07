module Semversion
  class Semver
    attr_accessor :major, :minor, :patch

    def self.semver?(str)
      return false if str.nil?

      parts = str.split('.')
      return false if parts.length != 3 || !parts.map { |p| p.to_i.to_s == p }.all?

      true
    end

    def initialize(version)
      (@major, @minor, @patch) = version.split('.')
    end

    def sort(other)
      return 1 if other.major < @major
      return -1 if other.major > @major

      return 1 if other.minor < @minor
      return -1 if other.minor > @minor

      return 1 if other.patch < @patch
      return -1 if other.patch > @patch

      0
    end
  end
end
