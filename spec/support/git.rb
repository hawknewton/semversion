# frozen_string_literal: true

require 'tmpdir'

def fixture_repo(&block)
  tmpdir = Dir.mktmpdir
  Dir.chdir(tmpdir) do
    `git init`
    `git commit --allow-empty -m 'initial commit'`
    block&.call
  end

  tmpdir
end
