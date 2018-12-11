# MalariaGEN binder

This repository contains installation scripts and environment definitions
for conda and texlive, for standardising environments across the
MalariaGEN resource centre team.

## Proposing changes

If you want to propose changes to this repository, e.g., add or update
a package in environment.yml, please submit a pull request. The following
commands show a typical workflow for doing this:

- If you don't already have a local clone of the binder repo, create one with:

```
git clone git@github.com:malariagen/binder.git
```

- Update your local master branch:

```
cd /path/to/local/clone/of/binder
git checkout master
git pull
```

- Create a new issue at https://github.com/malariagen/binder/issues
- Create a new branch for the work you want to do, naming the branch using the issue number and a descriptive slug, e.g.:

```
git checkout -b 10-add-pymysql-package
git push -u origin 10-add-pymysql-package
```

- Make relevant changes (e.g. to environment.yml) and then add, commit and push the changes, e.g.:

```
git add environment.yml
git commit -m 'add pymysql package #10'
git push
```

- Come back here to https://github.com/malariagen/binder and you should now see an option to create a pull request for your new branch. Click this.
- Assuming this issue would be resolved by the pull request, include the text "resolves #10" in the PR description (replacing "10" with whatever is the issue number being resolved). This will mean that when the PR is merged, the corresponding issue will automatically get closed.

## Usage

This repo is intended to be used as a git submodule within another
repo. This typically involves three distinct steps:

1. Add binder as a submodule to your repo. This only needs to be done once per repo. Note that someone else might already have done this for your repo of interest (the repo will include a ```binder``` sub-directory if that is the case)
1. Run the install script for each local clone of the repo. This needs to be done for each local clone you have, for example you might need to do this separately for one clone on your local machine and a second clone on a server.
1. Update the binder submodule. This needs to be done every time you know there have been changes made to the binder repo, and you want to move the submodule forward within your working repo.

The following sub-sections give commands for each of the above.

### Add binder as a submodule
For example, to use this within the malariagen/vector-ops repo,
do:

```
cd /path/to/local/clone/of/vector-ops
git submodule add git@github.com:malariagen/binder.git
git add --all
git commit -m 'add binder submodule'
```

### Run install script for a local clone

- If you don't already have a local clone of the repo, create one.  Note you need to use ```--recursive``` in order to pull in binder code. Example code for vector-ops repo:

```
git clone --recursive git@github.com:malariagen/vector-ops.git
```

- To run the conda installation script, do:

```
cd /path/to/local/clone/of/vector-ops
./binder/install-conda.sh
```

- Once conda is installed, you can activate the environment with:

```
source binder/env.sh
```

- Once activated, you can run a jupyter notebook with:

```
jupyter notebook
```

### Updating the binder submodule

If you know there have been changes made to the binder repo, and you
want to move the submodule forward within your working repo (e.g.,
vector-ops), do:

```
cd /path/to/local/clone/of/vector-ops
git checkout -b update-binder
cd binder
git checkout master
git pull
cd ..
git add binder
git commit -m 'update binder submodule'
git push -u origin update-binder 
```

This will create a branch called 'update-binder' with the submodule
moved forward. You can then get that into master via a PR, or merge it
into master manually, e.g.:

```
git checkout master
git merge update-binder
git push origin master
```

Once merged, don't forget to update your conda environment, e.g.:

```
cd /path/to/local/clone/of/vector-ops
./binder/install-conda.sh
```
