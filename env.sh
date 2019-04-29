#!/bin/bash

# determine containing directory
BINDERDIR=$(dirname "${BASH_SOURCE[0]}")

# setup environment variables
source ${BINDERDIR}/variables.sh

# activate conda environment
command -v conda > /dev/null && source activate $CONDANAME || echo "conda not installed"
