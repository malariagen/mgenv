#!/usr/bin/env bash

# This script:
# - Installs the relevant Miniforge version for the OS, if "miniforge.installed" doesn't exist.
# - Creates a conda environment named by $CONDANAME using the relevant pinned environment file at $ENVPINNED, if that exists.
# - Or, if $ENVPINNED does not exist, creates a conda environment named by $CONDANAME using the conda and pypi requirements,
#   and exports that environment to $ENVPINNED.

# N.B., assume this will be executed from the root directory of a repo
# where malariagen/mgenv is a submodule.

# ensure script errors if any command fails
set -e

# debug
# set -x

# determine containing directory
MGENVDIR="$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P )"

# setup environment variables
source ${MGENVDIR}/variables.sh

# ensure installation directory exists
mkdir -pv $INSTALLDIR

# change into into installation directory
cd $INSTALLDIR

# install miniforge
if [ ! -f miniforge.installed ]; then
    echo "[mgenv] installing miniforge to $INSTALLDIR"

    # clean up any previous
    rm -rf "conda"

    if [ "$(uname)" == "Darwin" ]; then
        # Install for Mac OS X platform
        # download miniforge
        # https://github.com/conda-forge/miniforge/blob/main/README.md
        curl -fsSLo Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-$(uname -m).sh"

        # install miniforge
        bash Miniforge3.sh -b -p "conda"

    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        # Install for GNU/Linux platform
        # download miniforge
        # https://github.com/conda-forge/miniforge/blob/main/README.md
        wget -O Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"

        # install miniforge
        bash Miniforge3.sh -b -p "conda"

    fi

    # mark success
    touch miniforge.installed

else
    echo "[mgenv] miniforge.installed exists, skipping miniforge installation"
fi

# return to original location
cd $REPODIR

# activate conda
echo "[mgenv] activating conda"
source "$INSTALLDIR/conda/etc/profile.d/conda.sh"

# set conda channel options
CHANNEL_OPTS="--override-channels --channel conda-forge --channel bioconda"

echo "[mgenv] installing conda-libmamba-solver"
conda install $CHANNEL_OPTS --yes conda-libmamba-solver
conda config --set solver libmamba

echo "[mgenv] showing pything version, conda version, conda list conda-libmamba-solver"
python --version
conda --version
conda list conda-libmamba-solver

echo "[mgenv] determining OS"
if [ "$(uname)" == "Darwin" ]; then
    OS=macos-latest
else
    OS=ubuntu-latest
fi
echo "[mgenv] OS: $OS"

ENVPINNED=${MGENVDIR}/environment-pinned-${OS}.yml

if [ -f "$ENVPINNED" ]; then
    # Here we build the environment from the pinned definition file,
    # which is what we expect mgenv users to do.
    echo "[mgenv] creating environment $CONDANAME from $ENVPINNED"
    conda env create -v --yes --name $CONDANAME --file $ENVPINNED

else
    # Here we build the environment from the unpinned requirements files,
    # which is what mgenv maintainers do to upgrade the pinned definition files.
    echo "[mgenv] (re)creating $ENVPINNED using requirements"
    
    echo "[mgenv] removing environment $CONDANAME if it exists"
    conda env remove -v --name=$CONDANAME || true
    
    echo "[mgenv] creating environment $CONDANAME and installing conda requirements"
    conda create --yes -v --strict-channel-priority $CHANNEL_OPTS --name $CONDANAME --file ${MGENVDIR}/requirements-conda.txt --file ${MGENVDIR}/requirements-compilers-${OS}.txt
    
    echo "[mgenv] activating environment $CONDANAME"
    conda activate $CONDANAME
    
    echo "[mgenv] installing pypi requirements into environment $CONDANAME"
    pip install -v -r ${MGENVDIR}/requirements-pypi.txt
    
    # N.B., here we add the conda-forge/label/broken channel so that the install
    # will still work in the future, even if some conda-forge packages have been
    # moved to the broken channel.
    echo "[mgenv] exporting environment $CONDANAME to $ENVPINNED"
    conda env export -v $CHANNEL_OPTS --channel=conda-forge/label/broken --name=$CONDANAME > $ENVPINNED
    
    echo "*** START $ENVPINNED ***"
    cat $ENVPINNED
    echo "*** END $ENVPINNED ***"

fi
