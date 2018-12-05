#!/bin/bash

# add miniconda to the path
export PATH=$(pwd)/deps/conda/bin:$PATH

# add texlive to the path
export PATH=$(pwd)/deps/texlive/bin/x86_64-linux:$PATH

# determine name of current directory, use as conda environment name
CONDANAME=${PWD##*/}

# activate conda environment
source activate $CONDANAME
