#!/bin/bash

# Convenience script to manually install texlive on a local system.

# N.B., assume this will be executed from the root directory of a github repo
# where the malariagen/mgenv repo is a submodule.

# ensure script errors if any command fails
set -e

# determine containing directory
MGENVDIR="$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P )"

# setup environment variables
source ${MGENVDIR}/variables.sh

# ensure installation directory exists
mkdir -pv $TEXDIR

# change into into installation directory
cd $TEXDIR

# install texlive
if [ ! -f texlive.installed ]; then
    echo "[mgenv] installing texlive to ${TEXDIR}"

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
        -profile=${MGENVDIR}/texlive.profile \
        -no-persistent-downloads \
        -no-verify-downloads

    # mark successful installation
    touch texlive.installed

else
    echo "[mgenv] skipping texlive installation, assuming previously installed"
fi

# return to original location
cd $REPODIR

echo "[mgenv] installing additional texlive packages"
tlmgr option repository $TEXREPO
tlmgr_install="tlmgr install --no-persistent-downloads --no-verify-downloads --no-require-verification"
for package in $(cat ${MGENVDIR}/texlive.packages); do
    marker=${TEXDIR}/texlive.${package}.installed
    if [ ! -f $marker ]; then
        $tlmgr_install $package && touch $marker
    else
        echo "[mgenv] skipping $package, assuming previously installed"
    fi
done
