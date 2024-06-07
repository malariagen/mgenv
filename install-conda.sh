#!/usr/bin/env bash

# Convenience script to install miniconda on a local system.

# N.B., assume this will be executed from the root directory of a repo
# where malariagen/binder is a submodule.

# ensure script errors if any command fails
set -e

# debug
# set -x

# determine containing directory
BINDERDIR="$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P )"

# setup environment variables
source ${BINDERDIR}/variables.sh

# ensure installation directory exists
mkdir -pv $INSTALLDIR

# change into into installation directory
cd $INSTALLDIR

# install miniconda
if [ ! -f miniconda.installed ]; then
    echo "[binder] installing miniconda to $INSTALLDIR"

    # clean up any previous
    rm -rf conda

    if [ "$(uname)" == "Darwin" ]; then
        # Install for Mac OS X platform
        # download miniconda
        curl --continue-at - --remote-name https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh

        # install miniconda
        bash Miniconda3-latest-MacOSX-x86_64.sh -b -p conda

    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        # Install for GNU/Linux platform
        # download miniconda
        wget --no-clobber https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

        # install miniconda
        bash Miniconda3-latest-Linux-x86_64.sh -b -p conda

    fi

    # mark success
    touch miniconda.installed

else
    echo "[binder] skipping miniconda installation"
fi

# return to original location
cd $REPODIR

# set conda channel options
CHANNEL_OPTS="--override-channels --channel conda-forge --channel bioconda --channel defaults"

echo "[binder] installing packages"

echo "[binder] install conda"
conda install $CHANNEL_OPTS --yes python=3.10 conda-libmamba-solver
conda config --set solver libmamba
python --version
conda --version
conda list conda-libmamba-solver

if [ "$(uname)" == "Darwin" ]; then
    OS=macos-latest
else
    OS=ubuntu-latest
fi

ENVPINNED=${BINDERDIR}/environment-pinned-${OS}.yml

if [ -f "$ENVPINNED" ]; then
    # Here we build the environment from the pinned definition file,
    # this is what we expect users to do.
    echo "[binder] creating environment $CONDANAME from $ENVPINNED"
    conda env create -v --yes --name $CONDANAME --file $ENVPINNED

else
    # Here we rebuild the environment from the unpinned requirements files,
    # which is what a maintainer will do when they want to upgrade the pinned
    # definition files.
    conda env remove -v --name=$CONDANAME
    echo "[binder] recreating $ENVPINNED"
    echo "[binder] installing conda packages"
    conda create --yes -v --strict-channel-priority $CHANNEL_OPTS --name $CONDANAME --file ${BINDERDIR}/requirements-conda.txt --file ${BINDERDIR}/requirements-compilers-${OS}.txt
    echo "[binder] installing packages from pypi"
    source activate $CONDANAME
    pip install -v -r ${BINDERDIR}/requirements-pypi.txt
    echo "[binder] exporting environment"
    # N.B., here we add the conda-forge/label/broken channel so that the install
    # will still work in the future, even if some conda-forge packages have been
    # moved to the broken channel.
    conda env export -v $CHANNEL_OPTS --channel=conda-forge/label/broken --name=$CONDANAME > $ENVPINNED
    echo "*** $ENVPINNED ***"
    cat $ENVPINNED
    echo "*** $ENVPINNED ***"

fi
