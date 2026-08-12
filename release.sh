#!/bin/bash

# Commit the chart source on `main`, package it, and leave the package in the
# gh-pages working tree. Driven by wekan/wekan's releases/release-charts.sh,
# which owns the version bump before this runs and rebuilds index.yaml after it;
# release2.sh then commits and pushes gh-pages.

if [ $# -ne 1 ]
  then
    echo "Syntax with Wekan version number:"
    echo "  ./release.sh 7.10"
    exit 1
fi

# THE CHART HAS NO DEPENDENCIES ANY MORE (#54, #55).
#
# This used to add groundhog2k's Helm repository and run `helm dependency
# update` + `build` to vendor their MongoDB chart into wekan/charts/. The
# database is FerretDB now and it is defined by THIS chart
# (wekan/templates/ferretdb-*.yaml), which is the fix for #54: the MONGO_URL was
# assembled from the naming of a chart nobody here controls, and pointed at a
# host that does not exist.
#
# So there is nothing to fetch, and the steps that fetched it are gone rather
# than left running against a repository the chart no longer uses. `helm` is not
# needed to package either - a chart package is a gzipped tar of the chart
# directory - so this no longer installs snapd and a snap of helm on a machine
# that may already have one. Anything that DOES need helm (linting, a test
# install) is the caller's to run.
#
# If a dependency is ever added back, this is where it is fetched:
#   helm repo add <name> <url> && helm dependency update wekan

git add --all
git commit -m "$1.0"
git push
tar -cvzf wekan-$1.0.tgz wekan
mv wekan-$1.0.tgz ..
git checkout gh-pages
mv ../wekan-$1.0.tgz .
echo "Update release sha256sum to release list."
