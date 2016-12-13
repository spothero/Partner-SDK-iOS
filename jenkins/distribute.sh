#!/bin/bash

LAST_GIT_MESSAGE="$(git log -1 --pretty=%B)"

# If this is a version bump, it's already being deployed. 
if [[ "$LAST_GIT_MESSAGE" == "Version Bump to"* ]]; then
    echo "This is just a version bump commit. No deployment will be done."
    exit 0
fi

# Make sure there's a fastlane password for sigh and pilot 
if [ -z "$FASTLANE_PASSWORD" ]; then
    echo "DISTRIBUTION FAIL: You need to add the FASTLANE_PASSWORD to Jenkins and/or local_config.sh for signing and ITC uploads to work."
    exit 1
fi

bundle install

# Upload the sample app to iTunes Connect
bundle exec fastlane sample_itc
