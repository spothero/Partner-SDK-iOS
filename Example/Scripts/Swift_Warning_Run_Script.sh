#!/bin/bash

# Makes it possible to grab comments with warnings and have the compiler emit warnings.
# source: http://bendodson.com/weblog/2014/10/02/showing-todo-as-warning-in-swift-xcode-project/
TAGS="WARN:"
echo "note: searching example app ${SRCROOT} for ${TAGS}..."

find "${SRCROOT}" \
    \( -name "*.swift" \) \
    -print0 \
    | xargs \
    -0 \
    egrep \
    --with-filename \
    --line-number \
    --only-matching \
    "($TAGS).*\$" \
    | perl \
    -p \
    -e "s/($TAGS)/ warning: \$1/"

DEV_POD_PATH="$(dirname ${SRCROOT})/SpotHero_iOS_Partner_SDK"        
echo "note: searching development pod ${DEV_POD_PATH} for ${TAGS}..."

find "${DEV_POD_PATH}" \
    \( -name "*.swift" \) \
    -print0 \
    | xargs \
    -0 \
    egrep \
    --with-filename \
    --line-number \
    --only-matching \
    "($TAGS).*\$" \
    | perl \
    -p \
    -e "s/($TAGS)/ warning: \$1/"