# Semversion

Semversion maintains semversion-compatible versions for your application using the following convention:

* If the current branch is `master`/`main` bump the minor version if the current version has gone to production, otherwise bump the patch
* If the current branch is a hotfix branch (`/^hotfix-[0-9]+\.[0-9]+$/`) bump the patch
* If the current branch is neither master, main, or hotfix throw an error

## Usage

There are two main commands:

* `semversion bumo` bumps the current version of the project
* `semversion release` marks the current version as having gone to production
