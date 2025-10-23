#!/bin/bash

# This script sets up the environment for using glooctl by downloading the latest version
# of glooctl and adding it to the user's PATH.
curl -sL https://run.solo.io/glooctl/install | sh
export PATH="$HOME/.glooctl/bin:$PATH"

echo "glooctl has been installed and added to your PATH."

glooctl version
glooctl install gateway