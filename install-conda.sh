#!/usr/bin/env bash

# Convenience script to install miniconda on a local system.

# N.B., assume this will be executed from the root directory of a repo
# where malariagen/binder is a submodule.

# ensure script errors if any command fails
set -e

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
        curl --continue-at - --remote-name https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh

        # install miniconda
        bash Miniconda3-latest-MacOSX-x86_64.sh -b -p conda

    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        # Install for GNU/Linux platform
        # download miniconda
        wget --no-clobber https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh

        # install miniconda
        bash Miniconda3-latest-Linux-x86_64.sh -b -p conda

    fi

    # update conda
    conda config --set channel_priority strict
    conda update --yes -c conda-forge conda

    # mark success
    touch miniconda.installed

else
    echo "[binder] skipping miniconda installation"
fi

# return to original location
cd $REPODIR

echo "[binder] installing packages"

echo "[binder] ensure channel order"
# N.B., cannot rely on environment.yml https://github.com/conda/conda/issues/7238
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --set channel_priority strict

echo "[binder] ensure conda is up to date"
conda update -c conda-forge --yes conda
conda --version

if [ "$(uname)" == "Darwin" ]; then
    ENVPINNED=${BINDERDIR}/environment-pinned-osx.yml
else
    ENVPINNED=${BINDERDIR}/environment-pinned-linux.yml
fi

if [ -f "$ENVPINNED" ]; then
    # Here we build the environment from the pinned definition file,
    # this is what we expect users to do.
    echo "[binder] creating environment $CONDANAME from pinned definition file"
    conda env remove -v --name=$CONDANAME
    conda env create -v --name $CONDANAME --file $ENVPINNED
else
    # Here we rebuild the environment from the unpinned file, which is
    # what a maintainer will do when they want to upgrade the pinned
    # definition files.
    echo "[binder] recreating $ENVPINNED"
    conda env remove -v --name=$CONDANAME
    conda env create -v --name=$CONDANAME --file ${BINDERDIR}/environment.yml
    conda env export -v --name=$CONDANAME > $ENVPINNED
    echo "*** $ENVPINNED ***"
    cat $ENVPINNED
    echo "*** $ENVPINNED ***"
fi

#if [[ -z "${MALARIAGEN_BINDER_HOME}" ]]; then
#    # clean conda caches
#    conda clean --yes --all
#fi
