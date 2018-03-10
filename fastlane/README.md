fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

## Choose your installation method:

| Method                     | OS support                              | Description                                                                                                                           |
|----------------------------|-----------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------|
| [Homebrew](http://brew.sh) | macOS                                   | `brew cask install fastlane`                                                                                                          |
| Installer Script           | macOS                                   | [Download the zip file](https://download.fastlane.tools). Then double click on the `install` script (or run it in a terminal window). |
| RubyGems                   | macOS or Linux with Ruby 2.0.0 or above | `sudo gem install fastlane -NV`                                                                                                       |

# Available Actions
## iOS
### ios test_pod
```
fastlane ios test_pod
```

### ios test
```
fastlane ios test
```
Runs all the tests of the sample app
### ios test_all
```
fastlane ios test_all
```
Runs all the tests of the app and gathers code coverage across all versions of xcode
### ios bump_commit
```
fastlane ios bump_commit
```
Bumps the version, commits it to git with the appropriate tag, and pushes to the remote.
### ios sample_itc
```
fastlane ios sample_itc
```
Method to run after a successful merge.

Will bump/commit/tag/push the version and upload to iTunes Connect.

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
