#!/bin/bash

function deleteDuplicateFile()
{
    while read line
    do
        FILEPATH=$(echo "$line" | cut -d$'\t' -f2-)
        echo "rm -rf $FILEPATH"

    done < $1
}

deleteDuplicateFile 4delete.txt
