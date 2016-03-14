#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

function formatFile()
{
    while read line
    do
        MD5SUM=$(echo "$line" | cut -d' ' -f1)
        FILEPATH=$(echo "$line" | cut -d' ' -f3-)
        echo -e "$MD5SUM\t$FILEPATH"
    done < $1
}

function addFileSize()
{
    rm -rf sort_size.txt
    while read line
    do
        MD5SUM=$(echo "$line" | cut -d' ' -f1)
        FILEPATH=$(echo "$line" | cut -d' ' -f3-)
        echo -e "$MD5SUM\t$FILEPATH" >> sort_size.txt
    done < sort.txt
}

function doubleCheckDuplicateFile()
{
    OLD_MD5SUM=""
    OLD_FILEPATH=""
    while read line
    do
        MD5SUM=$(echo "$line" | cut -d$'\t' -f1)
        FILEPATH=$(echo "$line" | cut -d$'\t' -f2-)

        if [ "$MD5SUM" == "$OLD_MD5SUM" ]; then
            RESULT=$(diff "$FILEPATH" "$OLD_FILEPATH")

            if [ "$RESULT" == "" ]; then
                echo -e "$MD5SUM\t$FILEPATH"
            else
                echo "ERROR!!!"
            fi
        fi

        OLD_MD5SUM="$MD5SUM"
        OLD_FILEPATH="$FILEPATH"
    done < $1
}

function deleteDuplicateFile()
{
    while read line
    do
        FILEPATH=$(echo "$line" | cut -d$'\t' -f2-)
        rm -rf "$FILEPATH"

    done < $1
}

function confirm()
{
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " RESPONSE
    case $RESPONSE in [yY][eE][sS]|[yY])
        echo "yes"
        ;;
    *)
        echo "no"
        ;;
esac
}

if [ "$1" == "" ] || [ "$2" == "" ]; then
    echo "Usage: $0 path file_extension"
    exit
fi

echo "Step 1: find file and calcuate md5 sum..."
find "$1" -type f -name "*.$2" -print0 | xargs -0 md5sum > 1sum.txt

echo "Step 2: format file..."
formatFile 1sum.txt > 2sum_format.txt

echo "Step 3: sort..."
cat 2sum_format.txt | sort -k1 > 3sort.txt

echo "Step 4: double check duplicate file..."
doubleCheckDuplicateFile 3sort.txt > 4delete.txt

if [[ ! -s 4delete.txt ]]; then
    echo "find anything..."
    exit
fi

echo -e "Step 5: check these duplicate file in ""$RED""4delete.txt""$NC"
ANSWER=$(confirm "Delete these files? [y/N]")
if [ "$ANSWER" == "yes" ]; then
    deleteDuplicateFile 4delete.txt
fi
