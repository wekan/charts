#!/bin/bash

if [ $# -ne 1 ]
  then
    echo "Syntax with Wekan version number:"
    echo "  ./release.sh 1.1.3"
    exit 1
fi

tar -cvzf wekan-$1.tgz wekan
mv wekan-$1.tgz ..
git checkout gh-pages
mv ../wekan-$1.tgz .
echo "Update release sha256sum to release list."
