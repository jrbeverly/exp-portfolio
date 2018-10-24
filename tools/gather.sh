#!/bin/bash

# Variables
DIR="$(dirname "$(readlink -f "$0")")"
DIR_ROOT="$(dirname $DIR)"
DIR_SRC="${DIR_ROOT}/src"
DIR_REF="${DIR_SRC}/ref"
DIR_BRIEF="${DIR_SRC}/brief"
DIR_INDEX="${DIR_SRC}/brief"
DIR_TMP="${DIR_ROOT}/.artifacts"
DIR_ARTIFACTS="${DIR_ROOT}/dist"
DIR_ARTIFACTS_REF="${DIR_ARTIFACTS}/ref"
DIR_ARTIFACTS_BRIEF="${DIR_ARTIFACTS}/brief"
DIR_ARTIFACTS_GIT="${DIR_ARTIFACTS}/tmp"

FILE_REPO="${DIR}/REPOSITORIES"

rm -rf $DIR_TMP
rm -rf $DIR_ARTIFACTS
mkdir -p $DIR_ARTIFACTS
mkdir -p $DIR_ARTIFACTS_REF
mkdir -p $DIR_ARTIFACTS_BRIEF
mkdir -p $DIR_TMP

cp -r "${DIR_INDEX}/." $DIR_ARTIFACTS/.
rm $DIR_ARTIFACTS/brief.html

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
            mkdir -p "images/"

            echo "$dirname: Working with brief"

            git_url=$(echo $repo| tr : /| cut -d'@' -f 2)
            url="https://${git_url%.git}"

            ## Get the properties from repository
            (
                cd "$DIR_TMP"
                git clone $repo
                cd $dirname

                cp "docs/icon/icon.svg" "$outDir/images/icon.svg"
                cp "README.md" "$outDir/README.md"
            )
            
            ## Briefs for projects           
            cp -r "${DIR_BRIEF}/." . 
            
            docker run -v $(pwd):/source jagregory/pandoc -f markdown -t html5 README.md -o output.html

            sed -i "s,%URL%,${url},g" index.html
            sed -i "s,%REPOSITORY%,${dirname},g" index.html
            sed -i -e '/<!--BODY-->/r output.html' index.html

            cp "${DIR_INDEX}/brief.html" brief.html
            sed -i "s,%REPOSITORY%,${dirname},g" brief.html
            sed -i -e '/<!--BODY-->/r brief.html' "$DIR_ARTIFACTS_BRIEF/index.html"            

            rm brief.html
            rm output.html
            rm README.md
        )
    )
    exit 1
done < "${FILE_REPO}"