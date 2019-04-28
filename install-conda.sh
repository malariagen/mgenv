#!/usr/bin/env bash

# Convenience script to install miniconda on a local system.

# N.B., assume this will be executed from the root directory of a repo
# where malariagen/binder is a submodule.

# ensure script errors if any command fails
set -e

# conda environment name - use name of current directory
CONDANAME=${PWD##*/}

# remember directory where this script was run from
REPODIR=${PWD}

# determine directory in which conda will be installed
if [[ -z "${MALARIAGEN_BINDER_INSTALLDIR}" ]]; then
    # if not specified by user, default installation location
    INSTALLDIR=${REPODIR}/binder/deps
else
    # allow user to specify installation location
    INSTALLDIR=${MALARIAGEN_BINDER_INSTALLDIR}
fi

# ensure installation directory exists
mkdir -pv $INSTALLDIR

# change into into installation directory
cd $INSTALLDIR

# put conda on the path
export PATH=${INSTALLDIR}/conda/bin:$PATH

# install miniconda
if [ ! -f miniconda.installed ]; then
    echo "[install] installing miniconda"

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

    # set conda channels
    conda config --add channels conda-forge
    conda update --yes conda

    # create default scientific Python environment
    conda create --yes --name=$CONDANAME python=3.6

    # mark success
    touch miniconda.installed

else
    echo "[install] skipping miniconda installation"
fi

# return to original location
cd $REPODIR

echo "[install] installing packages"

# ensure channel order - cannot rely on environment.yml
# https://github.com/conda/conda/issues/7238
conda config --add channels pyviz/label/dev
conda config --add channels bokeh/label/dev
conda config --add channels intake
conda config --add channels bioconda
conda config --add channels conda-forge

# ensure conda is up to date
conda update --yes conda

# install packages
conda env update --name $CONDANAME --file ./binder/environment.yml

# clean conda caches
conda clean --yes --all
