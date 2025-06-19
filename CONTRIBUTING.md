# Contributing

This document contains notes about development and testing of jmespath, the [Contributor Documentation](Contributor%20Documentation) folder has some more in-depth documents.

## Building & Testing

As a SwiftPM package, anything that supports packages can be used - opening in Xcode, Visual Studio Code with [Swift for Visual Studio Code](https://github.com/swift-server/vscode-swift) installed, or through the command line using `swift build` and `swift test`.

> [!NOTE]
> In order to skip long-running tests:
> - In Xcode
>   1. Product -> Scheme -> Edit Scheme…
>   2. Select the Arguments tab in the Run section
>   3. Add a `SKIP_LONG_TESTS` environment variable with value `1`
> - On the command line: Set the `SKIP_LONG_TESTS` environment variable to `1` when running tests, e.g by running `SKIP_LONG_TESTS=1 swift test`

## Formatting

The following package is formatted using [swift-format](http://github.com/swiftlang/swift-format) to ensure a consistent style.

To make format changes, run the formatter using the following command:

```bash
swift format --in-place --parallel --recursive .
```

Generated source code is not formatted to make it easier to spot changes when re-running code generation.

> [!NOTE]
> You can add a git hook to ensure all commits to the jmespath repository are correctly formatted.
> 1. Save the following contents to `.git/hooks/pre-commit`
> ```bash
> #!/usr/bin/env bash
> set -e
> SOURCE_DIR=$(realpath "$(dirname $0)/../..")
> swift format lint --strict --parallel --recursive $SOURCE_DIR
> ```
> 2. Mark the file as executable: `chmod a+x .git/hooks/pre-commit`
> 3. If you have global git hooks installed, be sure to call them at the end of the script with `path/to/global/hooks/pre-commit "$@"`

## Authoring commits

Prefer to squash the commits of your PR (*pull request*) and avoid adding commits like “Address review comments”. This creates a clearer git history, which doesn’t need to record the history of how the PR evolved.

We prefer to not squash commits when merging a PR because, especially for larger PRs, it sometimes makes sense to split the PR into multiple self-contained chunks of changes. For example, a PR might do a refactoring first before adding a new feature or fixing a bug. This separation is useful for two reasons:
- During review, the commits can be reviewed individually, making each review chunk smaller
- In case this PR introduced a bug that is identified later, it is possible to check if it resulted from the refactoring or the actual change, thereby making it easier find the lines that introduce the issue.

## Opening a PR

To submit a PR you don't need permissions on this repository, instead, you can fork and create a PR through the forked version.

For more information and instructions, read the GitHub docs on [forking a repo](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/fork-a-repo).

Once you've pushed your branch, you should see an option on this repository's page to create a PR from a branch in your fork.

> [!TIP]
> If you are stuck, it’s encouraged to submit a PR that describes the issue you’re having, e.g. if there are tests that are failing, build failures you can’t resolve, or if you have architectural questions. We’re happy to work with you to resolve those issue.

## Review and CI Testing

After you opened your PR, a maintainer will review it and test your changes in CI (*Continuous Integration*) by adding a `@swift-ci Please test` comment on the pull request. Once your PR is approved and CI has passed, the maintainer will merge your pull request.

Only contributors with commit access are able to approve pull requests and trigger CI.

## Additional Verification

The following package has additional verification methods that provide more extensive validation. They have a significant runtime impact and are thus not enabled by default when building, but are enabled in CI. If CI fails and you are unable to reproduce the failure locally, make sure that `SKIP_LONG_TESTS` is not set and try enabling these validations.

## Swift Version

We require that jmespath builds with the latest released compiler and the previous major version (e.g. with Swift 5.8 and Swift 5.7).
