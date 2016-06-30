#!/bin/bash
#Run script for http://swiftcleanapp.com/
if [[ -z ${SKIP_SWIFTCLEAN} || ${SKIP_SWIFTCLEAN} != 1 ]]; then
    if [[ -d "${LOCAL_APPS_DIR}/Swift-Clean.app" || -d "${LOCAL_APPS_DIR}/Swift-Clean.app" ]]; then
        #Scan main app
        "${LOCAL_APPS_DIR}"/Swift-Clean.app/Contents/Resources/SwiftClean.app/Contents/MacOS/SwiftClean "${SRCROOT}"
        
        #TODO: Get this to actually work. 
        #Scan development pod
        DEV_POD_PATH="$(dirname ${SRCROOT})/SpotHero_iOS_Partner_SDK"        
        "${LOCAL_APPS_DIR}"/Swift-Clean.app/Contents/Resources/SwiftClean.app/Contents/MacOS/SwiftClean "${DEV_POD_PATH}"
    else
        echo "warning: You have to install and set up Swift-Clean to use its features!"
    fi
fi
