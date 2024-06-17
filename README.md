# Semversion

## The Idea

I like [Semantic Versioning](https://semver.org/).  It's not perfect and falls down when you're versioning something other than an API but so far I think it's one of the better solutions out there when talking about versions of an artifact.

The basic idea is that (generally) you'll bump the patch version of your application until it goes to production and you start on the next feature set.  Therefore, every time you build a release candidate call `semversion bump` just before you build.  This will bump the version in your souce and push a tag to the origin git repo.

Next, you build your software as usual, using the version denoted in your repo as the coordinates for your deployable.  The can happen one or more times as you stabalize your code and pass your test suite.

After you push to production, call `semversion release`.  This command annotates your git repo (via git notes) denoting the passed version has gone to production.

A subsaquent call to `subversion bump` will reset the patch and bump the minor *UNLESS* you run it on a hotfix branch (a branch named hotfix-major.minor).

Semversion maintains semversion-compatible versions for your application using the following convention:

* If the current branch is `master`/`main` bump the minor version if the current version has gone to production, otherwise bump the patch
* If the current branch is a hotfix branch (`/^hotfix-[0-9]+\.[0-9]+$/`) bump the patch
* If the current branch is neither master, main, or hotfix throw an error

## Usage

There are two main commands:

* `semversion bumo` bumps the current version of the project
* `semversion release <origin repo> <version >` marks the version as having gone to production
