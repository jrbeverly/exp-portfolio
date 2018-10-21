#!/bin/bash

# Variables
DIR="$(dirname "$(readlink -f "$0")")"
DIR_ROOT="$(dirname $DIR)"
DIR_SRC="${DIR_ROOT}/src"
DIR_REF="${DIR_SRC}/ref"
DIR_ARTIFACTS="${DIR_ROOT}/.artifacts/ref"

FILE_REPO="${DIR}/REPOSITORIES"

rm -rf $DIR_ARTIFACTS
mkdir -p $DIR_ARTIFACTS
while IFS="" read -r repo || [ -n "$repo" ]
do
    (
        cd $DIR_ARTIFACTS
        
        repo_name="${repo%.*}" 
        dirname=$(echo ${repo_name} | awk -F/ '{print $NF}')

        mkdir -p $dirname
        (
            cd $dirname

            echo "Working with git repository $dirname"

            git_url=$(echo $repo| tr : /| cut -d'@' -f 2)
            url="https://${git_url%.git}"

            ## References for projects
            cp -r "${DIR_REF}/." .
            sed -i "s,%URL%,${url},g" index.html
            sed -i "s,%REPOSITORY%,${dirname},g" index.html
        )
    )
done < "${FILE_REPO}"