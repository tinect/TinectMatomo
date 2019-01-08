#!/usr/bin/env bash

commit=$1
if [ -z ${commit} ]; then
    commit=$(git tag --sort=-creatordate | head -1)
    if [ -z ${commit} ]; then
        commit="master";
    fi
fi

# Remove old release
rm -rf TinectMatomo TinectMatomo-*.zip

# Build new release
mkdir -p TinectMatomo
git archive ${commit} | tar -x -C TinectMatomo
composer install --no-dev -n -o -d TinectMatomo
( find ./TinectMatomo -type d -name ".git" && find ./TinectMatomo -name ".gitignore" && find ./TinectMatomo -name ".gitmodules" ) | xargs rm -r
zip -r TinectMatomo-${commit}.zip TinectMatomo