# MalariaGEN conda and texlive environment

This repository contains installation scripts and environment
definitions for conda and texlive, for standardising environments
across the MalariaGEN resource centre team.

## Usage

This repo is intended to be used as a git submodule within another
repo. This typically involves three distinct steps:

- Add the malariagen/mgenv repo as a submodule to your repo. This
  only needs to be done once per repo. Note that someone else might
  already have done this for your repo of interest (the repo will
  include a ```mgenv``` sub-directory if that is the case).

- Run the install script for each local clone of the repo. This needs
  to be done for each local clone you have, for example you might need
  to do this separately for one clone on your local machine and a
  second clone on a server.

- Update the mgenv submodule. This needs to be done every time you
  know there have been changes made to the mgenv repo, and you want
  to move the submodule forward within your working repo.

The following sub-sections give commands for each of the above.

### Add mgenv as a submodule

It is recommended that you first create an issue for doing this within
your repo with a title such as "Add mgenv". Then create a new branch,
add mgenv submodule, and create a pull request. It is also recommend
that you add 'deps' to the .gitignore file for the repo, so that once
the install command has been run (see next section), the deps
directory this is installed into will not come under git tracking. For
example, to use this within the malariagen/vector-ops repo, assuming
your new issue is number 10:

```
cd /path/to/local/clone/of/vector-ops
git checkout -b 10_add_mgenv
git push -u origin 10_add_mgenv
git submodule add git@github.com:malariagen/mgenv.git
git add --all
git commit -m 'add mgenv submodule'
git push
```

At this point create a pull request for your new branch, and then pull
the changes into master, deleting the new branch. 

### Run install script for a local clone

If you don't already have a local clone of the repo, create one.
Note you need to use ```--recursive``` in order to pull in mgenv
code. Example code for vector-ops repo:

```
git clone --recursive git@github.com:malariagen/vector-ops.git
```

To run the conda installation script, do:

```
cd /path/to/local/clone/of/vector-ops
./mgenv/install-conda.sh
```

Once conda is installed, you can activate the environment with:

```
source mgenv/env.sh
```

Once activated, you can run a jupyter notebook on a local machine
with:

```
jupyter notebook
```

Or if you want to run a jupyter notebook on a server that you will
connect to from your local machine, you could run a command such as:

```
jupyter notebook --no-browser --ip=0.0.0.0 --port <port number>
```

### Updating the mgenv submodule

If you know there have been changes made to the mgenv repo, and you
want to move the submodule forward within your working repo (e.g.,
vector-ops), do:

```
cd /path/to/local/clone/of/vector-ops
git checkout -b update-mgenv
cd mgenv
git fetch
git checkout v2.1.0
cd ..
git add mgenv
git commit -m 'update mgenv submodule'
git push -u origin update-mgenv 
```

This will create a branch called 'update-mgenv' with the mgenv
submodule moved forward to the "v2.1.0" tag. You can then get that
into master via a PR.

Once merged, don't forget to update your conda environment on all
machines, e.g.:

```
cd /path/to/local/clone/of/vector-ops
./mgenv/install-conda.sh
```

## Proposing changes

If you want to propose changes to this repository, e.g., add or update
a package, please submit a pull request. The following commands show a
typical workflow for doing this.

If you don't already have a local clone of the mgenv repo, fork the
repo to your user account, then clone:

```
git clone git@github.com:yourusername/mgenv.git
```

Update your local master branch:

```
cd /path/to/local/clone/of/mgenv
git checkout master
git pull
```

Create a new issue at https://github.com/malariagen/mgenv/issues
describing the changes you propose to make.

Create a new branch for the work you want to do, naming the branch
using the issue number and a descriptive slug, e.g.:

```
git checkout -b 10-add-foo-package
git push -u origin 10-add-foo-package
```

Make changes to requirements-conda.txt or requirements-pypi.txt in a
text editor.

Delete the pinned environment files:

```
rm -v environment-pinned-*.yml
```

Commit the changes:

```
git add --all
git commit -m 'add foo package, wipe pinned environments'
git push
```

Come back here to https://github.com/malariagen/mgenv and make a
pull request.

After the PR is created, GitHub actions will automatically run to check
that the modified environment can be created, and will generate new
versions of the pinned environment files. If CI passes, go to the
actions, find and download the artifacts (which will contain new pinned environment files), then add them back in to your clone of the mgenv repo, and push to update the PR.

```
git add environment-pinned-ubuntu-latest.yml environment-pinned-macos-latest.yml
git commit -m 'add new pinned environment files from CI'
git push
```

GitHub actions will then run again to verify the pinned environment files can be used to create environments. If CI then passes, the pull request will be merged.
