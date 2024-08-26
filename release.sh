#!/bin/bash

if [ $# -ne 1 ]
  then
    echo "Syntax with Wekan version number:"
    echo "  ./release.sh 7.10"
    exit 1
fi

cd wekan
sudo apt -y install snapd
sudo snap install helm --classic
/snap/bin/helm repo add mongo https://charts.bitnami.com/bitnami
/snap/bin/helm dependency update
/snap/bin/helm dependency build
cd ..
git add --all
git commit -m "$1.0"
git push
tar -cvzf wekan-$1.0.tgz wekan
mv wekan-$1.0.tgz ..
git checkout gh-pages
mv ../wekan-$1.0.tgz .
echo "Update release sha256sum to release list."
