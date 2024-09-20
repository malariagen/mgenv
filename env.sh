#!/bin/bash

# determine containing directory
MGENVDIR=$(dirname "${BASH_SOURCE[0]}")

# setup environment variables
source ${MGENVDIR}/variables.sh

# activate conda environment
command -v conda > /dev/null && source activate $CONDANAME || echo "conda not installed"
