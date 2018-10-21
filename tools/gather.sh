#!/bin/bash

# Variables
DIR="$(dirname "$(readlink -f "$0")")"
DIR_ROOT="$(dirname $DIR)"
DIR_SRC="${DIR_ROOT}/src"
DIR_REF="${DIR_SRC}/ref"
DIR_BRIEF="${DIR_SRC}/brief"
DIR_TMP="${DIR_ROOT}/.artifacts/"
DIR_ARTIFACTS="${DIR_ROOT}/dist/"
DIR_ARTIFACTS_REF="${DIR_ARTIFACTS}/ref/"
DIR_ARTIFACTS_BRIEF="${DIR_ARTIFACTS}/brief"
DIR_ARTIFACTS_GIT="${DIR_ARTIFACTS}/tmp"

FILE_REPO="${DIR}/REPOSITORIES"

rm -rf $DIR_TMP
rm -rf $DIR_ARTIFACTS
mkdir -p $DIR_ARTIFACTS
mkdir -p $DIR_ARTIFACTS_REF
mkdir -p $DIR_ARTIFACTS_BRIEF
mkdir -p $DIR_TMP

while IFS="" read -r repo || [ -n "$repo" ]
do
    (
        repo_name="${repo%.*}" 
        dirname=$(echo ${repo_name} | awk -F/ '{print $NF}')
        echo "$dirname: Working with git repository"

        (
            outDir="$DIR_ARTIFACTS_REF/$dirname"
            mkdir -p "$outDir"
            cd "$outDir"

            echo "$dirname: Working with reference"

            git_url=$(echo $repo| tr : /| cut -d'@' -f 2)
            url="https://${git_url%.git}"

            ## References for projects
            
            cp -r "${DIR_REF}/." .
            sed -i "s,%URL%,${url},g" index.html
            sed -i "s,%REPOSITORY%,${dirname},g" index.html
        )

        
        (
            outDir="$DIR_ARTIFACTS_BRIEF/$dirname"
            mkdir -p "$outDir"
            cd "$outDir"

            echo "$dirname: Working with brief"

            git_url=$(echo $repo| tr : /| cut -d'@' -f 2)
            url="https://${git_url%.git}"

            ## Get the properties from repository
            gitPath="$DIR_TMP/$dirname"
            git clone $repo "$gitPath"
            iconPath="docs/icon/icon.svg"

            ## Briefs for projects           
            cp -r "${DIR_BRIEF}/." .
            mkdir -p "images/"
            cp "$gitPath/$iconPath" images/icon.svg
            cp "$gitPath/README.md" README.md
   
            docker run -v $(pwd):/source jagregory/pandoc -f markdown -t html5 README.md -o output.html

            sed -i "s,%URL%,${url},g" index.html
            sed -i "s,%REPOSITORY%,${dirname},g" index.html
            # sed -i "s@%BODY%@${contents}@g" index.html
            sed -i -e '/<!--BODY-->/r output.html' index.html
        )

    )
    exit
done < "${FILE_REPO}"