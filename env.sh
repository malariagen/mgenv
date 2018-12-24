#!/bin/bash

# add miniconda to the path
export PATH=$(pwd)/binder/deps/conda/bin:$PATH

# add texlive to the path
if [ "$(uname)" == "Darwin" ]; then
    export PATH=$(pwd)/binder/deps/texlive/bin/x86_64-darwin:$PATH
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    export PATH=$(pwd)/binder/deps/texlive/bin/x86_64-linux:$PATH
fi

# determine name of current directory, use as conda environment name
CONDANAME=${PWD##*/}

# activate conda environment
source activate $CONDANAME
