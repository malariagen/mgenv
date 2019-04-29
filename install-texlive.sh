#!/bin/bash

# Convenience script to manually install texlive on a local system.

# N.B., assume this will be executed from the root directory of a github repo
# where the malariagen/binder repo is a submodule.

# ensure script errors if any command fails
set -e

# determine containing directory
BINDERDIR=$(dirname "$0")

# setup environment variables
source ${BINDERDIR}/variables.sh

# ensure installation directory exists
mkdir -pv $TEXDIR

# change into into installation directory
cd $TEXDIR

# install texlive
if [ ! -f texlive.installed ]; then
    echo "[install] installing texlive to ${TEXDIR}"

    # clean up any previous
    rm -rvf texlive*
    rm -rvf install*

    # download texlive
    wget ${TEXREPO}/install-tl-unx.tar.gz

    # unpack archive
    tar zxvf install-tl-unx.tar.gz

    # run installation
    ./install-tl-*/install-tl \
        -repository=$TEXREPO \
        -profile=../texlive.profile \
        -no-persistent-downloads \
        -no-verify-downloads

    # mark successful installation
    touch texlive.installed

else
    echo "[install] skipping texlive installation"
fi

# return to original location
cd $REPODIR

echo "[install] installing additional texlive packages"
tlmgr option repository $TEXREPO
tlmgr_install="tlmgr install --no-persistent-downloads --no-verify-downloads --no-require-verification"
for package in $(cat binder/texlive.packages); do
    $tlmgr_install $package
done
