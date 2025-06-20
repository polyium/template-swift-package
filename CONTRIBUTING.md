# Contributing

The following document contains notes about development and testing. Please see 
[the `Documentation` directory](./Documentation) for more additional development-related
specifics.

## Building & Testing

As a SwiftPM package, anything that supports packages can be used - opening in Xcode, Visual Studio Code with [Swift for Visual Studio Code](https://github.com/swift-server/vscode-swift) installed, or through the command line using `swift build` and `swift test`.

> [!NOTE]
> In order to skip long-running tests:
> - In Xcode
>   1. Product -> Scheme -> Edit Scheme…
>   2. Select the Arguments tab in the Run section
>   3. Add a `SKIP_LONG_TESTS` environment variable with value `1`
> - On the command line: Set the `SKIP_LONG_TESTS` environment variable to `1` when running tests, e.g by running `SKIP_LONG_TESTS=1 swift test`



## How to submit a bug report

Please ensure to specify the following:

* AsyncHTTPClient commit hash
* Contextual information (e.g. what you were trying to achieve with AsyncHTTPClient)
* Simplest possible steps to reproduce
  * More complex the steps are, lower the priority will be.
  * A pull request with failing test case is preferred, but it's just fine to paste the test case into the issue description.
* Anything that might be relevant in your opinion, such as:
  * Swift version or the output of `swift --version`
  * OS version and the output of `uname -a`
  * Network configuration


### Example

```
AsyncHTTPClient commit hash: 22ec043dc9d24bb011b47ece4f9ee97ee5be2757

Context:
While load testing my program written with AsyncHTTPClient, I noticed
that one file descriptor is leaked per request.

Steps to reproduce:
1. ...
2. ...
3. ...
4. ...

$ swift --version
Swift version 4.0.2 (swift-4.0.2-RELEASE)
Target: x86_64-unknown-linux-gnu

Operating system: Ubuntu Linux 16.04 64-bit

$ uname -a
Linux beefy.machine 4.4.0-101-generic #124-Ubuntu SMP Fri Nov 10 18:29:59 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux

My system has IPv6 disabled.
```

## Writing a Patch

A good patch is:

1. Concise, and contains as few changes as needed to achieve the end result.
2. Tested, ensuring that any tests provided failed before the patch and pass after it.
3. Documented, adding API documentation as needed to cover new functions and properties.
4. Accompanied by a great commit message, using our commit message template.

### Commit Message Template

We require that your commit messages match our template. The easiest way to do that is to get git to help you by explicitly using the template. To do that, `cd` to the root of our repository and run:

    git config commit.template git.commit.template

### Run CI Checks Locally

You can run the Github Actions workflows locally using [act](https://github.com/nektos/act). For detailed steps on how to do this please see [https://github.com/swiftlang/github-workflows?tab=readme-ov-file#running-workflows-locally](https://github.com/swiftlang/github-workflows?tab=readme-ov-file#running-workflows-locally).

#### Act

[Install act](https://nektosact.com/installation/) and then you can run the full suite of checks via:
```
act pull_request
```

## How to Contribute Your Work

Please open a pull request at https://github.com/swift-server/async-http-client. Make sure the CI passes, and then wait for code review.

## Authoring Commits

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

## Review

After you opened your PR, a maintainer will review it and test your changes in CI (*Continuous Integration*) by adding a `@swift-ci Please test` comment on the pull request. Once your PR is approved and CI has passed, the maintainer will merge your pull request.

Only contributors with commit access are able to approve pull requests and trigger CI.

## Formatting

Try to keep your lines less than 120 characters long so GitHub can correctly display your changes.

SwiftNIO uses the [swift-format](https://github.com/swiftlang/swift-format) tool to bring consistency to code formatting.  There is a specific [.swift-format](./.swift-format) configuration file.  This will be checked and enforced on PRs.  Note that the check will run on the current most recent stable version target which may not match that in your own local development environment.

If you want to apply the formatting to your local repo before you commit then you can either run [check-swift-format.sh](https://github.com/swiftlang/github-workflows/blob/main/.github/workflows/scripts/check-swift-format.sh) which will use your current toolchain, or to match the CI checks exactly you can use `act` (see [act section](#act)):
```
act --action-offline-mode --bind workflow_call --job soundness --input format_check_enabled=true
```

If you're using a machine with an ARM64 architecture (such as an Apple Silicon Mac) then
you'll also need to specify the container architecture:
```
act --container-architecture linux/amd64 --action-offline-mode --bind workflow_call --job soundness --input format_check_enabled=true
```

This will run the format checks, binding to your local checkout so the edits made are to your own source.


## Swift Version

We require builds with the version specified in `.swift-version`.
