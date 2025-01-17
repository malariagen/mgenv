#!/bin/bash

# determine containing directory
MGENVDIR=$(dirname "${BASH_SOURCE[0]}")

# setup environment variables
# Note: this also adds "$INSTALLDIR/conda/bin" to $PATH
echo "[mgenv] setting environmental variables"
source ${MGENVDIR}/variables.sh

# activate conda
echo "[mgenv] activating conda"
source "$INSTALLDIR/conda/etc/profile.d/conda.sh"

# activate conda environment
echo "[mgenv] activating environment $CONDANAME"
command -v conda > /dev/null && conda activate $CONDANAME || echo "conda not installed"
