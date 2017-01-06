#!/bin/bash

# Force a bundle install
bundle install

# Use fastlane to run all our tests on Xcode 7.3.1 + 8 
bundle exec fastlane test_all
