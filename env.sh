#!/bin/bash

# set path to repository
REPODIR="$( cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd -P )"

# determine directory in which conda is installed
if [[ -z "${MALARIAGEN_BINDER_INSTALLDIR}" ]]; then
    # if not specified by user, default installation location
    INSTALLDIR=${REPODIR}/binder/deps
else
    # allow user to specify installation location
    INSTALLDIR=${MALARIAGEN_BINDER_INSTALLDIR}
fi

# determine name of repository directory, use as conda environment name
CONDANAME=${REPODIR##*/}

# add miniconda to the path
export PATH=${INSTALLDIR}/conda/bin:$PATH

# add texlive to the path - N.B., texlive is always installed in default location,
# because there is no way to create separate environments for separate repos within
# the same installation
TEXLIVEDIR=${REPODIR}/binder/deps/texlive
if [ "$(uname)" == "Darwin" ]; then
    export PATH=${TEXLIVEDIR}/bin/x86_64-darwin:$PATH
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    export PATH=${TEXLIVEDIR}/bin/x86_64-linux:$PATH
fi

# activate conda environment
source activate $CONDANAME
