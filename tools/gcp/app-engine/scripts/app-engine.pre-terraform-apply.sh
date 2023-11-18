#!/bin/sh

# fail if any called scripts fail
set -e

# figure out the next app version
./app-engine.set-next-version.sh