#!/bin/sh
#Run script for https://github.com/realm/SwiftLint
if which swiftlint >/dev/null; then
    swiftlint
else
    echo "warning: SwiftLint not installed, `brew install swiftlint` or download from https://github.com/realm/SwiftLint"
fi
