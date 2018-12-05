# MalariaGEN binder

This repository with installation scripts and environment definitions
for conda and texlive, for standardising environments across the
MalariaGEN resource centre team.

## Proposing changes

If you want to propose changes to this repository, e.g., add or update
a package in environment.yml, please submit a pull request.

## Usage

This repo is intended to be used as a git submodule within another
repo. For example, to use this within the malariagen/vector-ops repo,
do:

```
cd /path/to/local/clone/of/vector-ops
git submodule add git@github.com:malariagen/binder.git
git add --all
git commit -m 'add binder submodule'
```

To run the conda installation script, do:

```
./binder/install-conda.sh
```

Once conda is installed, you can activate the environment with:

```
source binder/env.sh
```

Once activated, you can run a jupyter notebook with:

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
