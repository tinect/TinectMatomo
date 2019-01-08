#!/usr/bin/env bash

commit=$1
pluginname=$PLUGIN_NAME
if [ -z ${commit} ]; then
    commit=$(git tag --sort=-creatordate | head -1)
    if [ -z ${commit} ]; then
        commit="master";
    fi
fi

# Remove old release
rm -rf ${pluginname} ${pluginname}-*.zip

# Build new release
mkdir -p ${pluginname}
git archive ${commit} | tar -x -C ${pluginname}
composer install --no-dev -n -o -d ${pluginname}
( find ./${pluginname} -type d -name ".git" && find ./${pluginname} -name ".gitignore" && find ./${pluginname} -name ".gitmodules" ) | xargs rm -r
zip -r ${pluginname}-${commit}.zip ${pluginname}