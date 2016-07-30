#!/bin/bash

# Force a bundle install
bundle install

# Use fastlane to run all our tests. 
fastlane test
