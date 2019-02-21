#!/bin/bash

# set path to repository
repoDir="$( cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd -P )"

# add miniconda to the path
export PATH=${repoDir}/binder/deps/conda/bin:$PATH

# add texlive to the path
if [ "$(uname)" == "Darwin" ]; then
    export PATH=${repoDir}/binder/deps/texlive/bin/x86_64-darwin:$PATH
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    export PATH=${repoDir}/binder/deps/texlive/bin/x86_64-linux:$PATH
fi

# determine name of repository directory, use as conda environment name
CONDANAME=${repoDir##*/}

# activate conda environment
source activate $CONDANAME
