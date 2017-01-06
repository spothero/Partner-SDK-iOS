fastlane documentation
================
# Installation
```
sudo gem install fastlane
```
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
More information about fastlane can be found on [https://fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [GitHub](https://github.com/fastlane/fastlane/tree/master/fastlane).
