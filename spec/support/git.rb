require 'tmpdir'

def fixture_repo(&block)
  tmpdir = Dir.mktmpdir
  Dir.chdir(tmpdir) do
    `git init`
    `git commit --allow-empty -m 'initial commit'`
    block.call if block
  end

  tmpdir
end
