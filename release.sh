#!/bin/bash

if [ $# -ne 1 ]
  then
    echo "Syntax with Wekan version number:"
    echo "  ./release.sh 1.1.4"
    exit 1
fi

cd wekan
helm dependency update
helm dependency build
cd ..
git add --all
git commit -m "$1"
git push
tar -cvzf wekan-$1.tgz wekan
mv wekan-$1.tgz ..
git checkout gh-pages
mv ../wekan-$1.tgz .
echo "Update release sha256sum to release list."
