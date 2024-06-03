#!/bin/bash

if [ $# -ne 1 ]
  then
    echo "Syntax with Wekan version number:"
    echo "  ./release.sh 1.1.4"
    exit 1
fi

cd wekan
sudo snap install helm
/snap/bin/helm repo add mongo https://charts.bitnami.com/bitnami
/snap/bin/helm dependency update
/snap/bin/helm dependency build
cd ..
git add --all
git commit -m "$1"
git push
tar -cvzf wekan-$1.tgz wekan
mv wekan-$1.tgz ..
git checkout gh-pages
mv ../wekan-$1.tgz .
echo "Update release sha256sum to release list."
