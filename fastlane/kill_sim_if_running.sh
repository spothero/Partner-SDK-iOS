#!/bin/bash

# Check if a simulator is running
if pgrep "Simulator" >/dev/null
then
    # Kill it with fire
    killall "Simulator"
fi

# Check if the Xcode 8 service is running
if pgrep "com.apple.CoreSimulator.CoreSimulatorService" >/dev/null
then
    # keeeel
    killall "com.apple.CoreSimulator.CoreSimulatorService"
fi
