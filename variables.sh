#!/bin/bash

# determine path to parent repository
REPODIR="$( cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd -P )"

# determine binder version
BINDERV=$( cd ${REPODIR}/binder && git rev-parse --short HEAD )

# determine directory in which conda is installed
if [[ -z "${MALARIAGEN_BINDER_HOME}" ]]; then
    # if not specified by user, default installation location
    INSTALLDIR=${REPODIR}/binder/deps
else
    # allow user to specify installation location
    INSTALLDIR=${MALARIAGEN_BINDER_HOME}
fi

# determine name of parent repository, use as conda environment name
CONDANAME=${REPODIR##*/}-$BINDERV

# add miniconda to the path
export PATH=${INSTALLDIR}/conda/bin:$PATH

# use a frozen mirror to get reproducible install
# unfortunately speedata.de doesn't seem to be working any more?
#TEXREPO=https://ctanmirror.speedata.de/2017-09-01/systems/texlive/tlnet
# this should be a frozen version of the 2017 distribution
TEXREPO=http://ftp.math.utah.edu/pub/tex/historic/systems/texlive/2017/tlnet-final
TEXDIST=texlive-2017

# add texlive to the path
TEXDIR=${INSTALLDIR}/${TEXDIST}
if [ "$(uname)" == "Darwin" ]; then
    export PATH=${TEXDIR}/texlive/bin/x86_64-darwin:$PATH
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    export PATH=${TEXDIR}/texlive/bin/x86_64-linux:$PATH
fi
