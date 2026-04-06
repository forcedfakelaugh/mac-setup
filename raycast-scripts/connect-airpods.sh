#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Connect AirPods Pro
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🎧
# @raycast.packageName Bluetooth

/opt/homebrew/bin/blueutil --connect f0-04-e1-bf-05-bb
