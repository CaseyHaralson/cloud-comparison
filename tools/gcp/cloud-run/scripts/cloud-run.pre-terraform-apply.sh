#!/bin/sh

# fail if any called scripts fail
set -e

# figure out the appropriate container image
./cloud-run.set-terraform-container-image-value.sh